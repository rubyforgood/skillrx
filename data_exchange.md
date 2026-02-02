## Protocol

### 1. Device Setup

**Flow:**
1. Admin creates a device entry in SkillRx, receives an API key (e.g., `sk_live_xxxxxxxxxxxxxxxx`)
2. Admin assigns language, regions, providers, topics, and tags to this device
3. Admin gives API key to device operator
4. Device operator enters the API key in SkillRx Beacon app
5. Device stores API key locally and uses it for all requests

The server identifies the device from the API key (each key is unique per device).

---

### 2. Manifest Structure

The manifest describes all content assigned to a device. Each file has a checksum to detect changes even without manifest version bump.

**Manifest Request:**
```
GET /api/v1/devices/me/manifest
Authorization: Bearer {api_key}
```

**Manifest Response:**
```json
{
  "manifest_version": "v42",
  "manifest_checksum": "sha256:abc123...",
  "generated_at": "2024-01-15T12:00:00Z",
  "language": {
    "id": 1,
    "code": "en",
    "name": "English"
  },
  "regions": [
    {
      "id": 5,
      "name": "East Region",
      "code": "east"
    }
  ],
  "tags": [
    {
      "id": 201,
      "name": "Prenatal"
    },
    {
      "id": 202,
      "name": "Emergency"
    }
  ],
  "providers": [
    {
      "id": 10,
      "name": "Health Ministry",
      "topics": [
        {
          "id": 100,
          "name": "Maternal Health",
          "tag_ids": [201],
          "files": [
            {
              "id": 1001,
              "filename": "prenatal_care_guide.pdf",
              "path": "providers/10/topics/100/prenatal_care_guide.pdf",
              "checksum": "sha256:def456...",
              "size_bytes": 2457600,
              "content_type": "application/pdf",
              "updated_at": "2024-01-10T08:00:00Z"
            }
          ]
        }
      ]
    }
  ],
  "total_size_bytes": 156000000,
  "total_files": 47
}
```

---

### 3. Sync Protocol

**3.1 Check for Updates (Lightweight)**

Before full sync, device checks if manifest changed:

```
HEAD /api/v1/devices/me/manifest
Authorization: Bearer {api_key}
If-None-Match: "v42"
```

**Response Headers:**
- `304 Not Modified` — no changes, device is up to date
- `200 OK` with `ETag: "v43"` — manifest changed, sync needed

**3.2 Full Sync Flow**

```
┌─────────────────┐                    ┌─────────────────┐
│  SkillRx Beacon │                    │     SkillRx     │
└────────┬────────┘                    └────────┬────────┘
         │                                      │
         │  1. GET /manifest                    │
         │─────────────────────────────────────>│
         │                                      │
         │  2. Manifest (v43, checksum: xyz)    │
         │<─────────────────────────────────────│
         │                                      │
         │  3. Compare with local manifest      │
         │     - Identify new files             │
         │     - Identify changed files         │
         │     - Identify deleted files         │
         │                                      │
         │  4. Download each needed file        │
         │     (to temp directory)              │
         │                                      │
    ┌────┴────┐                                 │
    │ For each│                                 │
    │  file   │                                 │
    └────┬────┘                                 │
         │  GET /files/{file_id}                │
         │─────────────────────────────────────>│
         │                                      │
         │  File content                        │
         │<─────────────────────────────────────│
         │                                      │
         │  Verify checksum matches             │
         │                                      │
         │  [If manifest changed during sync]   │
         │  ABORT, restart from step 1          │
         │                                      │
         │  5. Atomic swap: temp → production   │
         │                                      │
         │  6. POST /sync-status (success)      │
         │─────────────────────────────────────>│
         │                                      │
```

**3.3 File Download with Resume Support**

```
GET /api/v1/files/{file_id}
Authorization: Bearer {api_key}
Range: bytes=1048576-  (resume from 1MB if interrupted)
```

**Response:**
```
HTTP/1.1 206 Partial Content
Content-Range: bytes 1048576-2457599/2457600
Content-Type: application/pdf

[file bytes...]
```

**3.4 Manifest Change Detection During Sync**

Before downloading each file, device should check manifest hasn't changed:

```
HEAD /api/v1/devices/me/manifest
Authorization: Bearer {api_key}
If-Match: "v43"
```

- `200 OK` — manifest unchanged, continue downloading
- `412 Precondition Failed` — manifest changed, abort sync and restart

*Optimization:* Check every N files (e.g., every 5 files) instead of every file to reduce requests.

---

### 4. Sync Status Reporting

Device reports its sync status so SkillRx admin can see device health.

**Report Sync Status:**
```
POST /api/v1/devices/me/sync-status
Authorization: Bearer {api_key}
Content-Type: application/json

{
  "status": "synced",
  "manifest_version": "v43",
  "manifest_checksum": "sha256:xyz...",
  "synced_at": "2024-01-15T14:30:00Z",
  "files_count": 47,
  "total_size_bytes": 156000000,
  "device_info": {
    "hostname": "clinic-pc-001",
    "os_version": "Ubuntu 22.04",
    "app_version": "1.0.0"
  }
}
```

**Status Values:**
- `synced` — device has complete, up-to-date content
- `syncing` — sync in progress (include `progress_percent`)
- `outdated` — device knows it's behind but hasn't synced yet
- `error` — last sync failed (include `error_message`)

---

### 5. Local Storage Structure

SkillRx Beacon stores files atomically using a versioned directory approach:

```
/data/
├── current -> versions/v43     (symlink to active version)
├── versions/
│   ├── v43/
│   │   ├── manifest.json
│   │   └── files/
│   │       └── providers/10/topics/100/prenatal_care_guide.pdf
│   └── v42/                    (previous version, can be cleaned up)
├── downloading/                 (temp dir for in-progress sync)
│   ├── manifest.json
│   └── files/...
└── cache/                       (checksummed files for reuse)
    └── sha256_def456.../prenatal_care_guide.pdf
```

**Atomic Swap Process:**
1. Download all files to `downloading/`
2. Verify all checksums
3. Move `downloading/` to `versions/v43/`
4. Update `current` symlink to point to `versions/v43/`
5. Delete old versions (keep 1 previous for rollback)

**File Reuse via Cache:**
When a file's checksum matches one already in cache (from previous version), hard-link instead of re-downloading.

---

### 6. Error Handling

| Scenario | Device Behavior |
|----------|-----------------|
| Network timeout during file download | Retry 3 times with exponential backoff, then abort sync |
| Checksum mismatch after download | Delete file, re-download, if fails again abort sync |
| Manifest changed during sync | Abort immediately, restart with new manifest |
| 401 Unauthorized | Clear credentials, prompt for re-registration |
| 404 on file | Log error, abort sync (manifest inconsistency) |
| Disk full | Abort sync, report error status |

---

### 7. SkillRx Admin Dashboard Data

SkillRx can show admins:

```json
{
  "device_id": "dev_abc123",
  "name": "Clinic PC 001",
  "status": "synced",
  "current_manifest_version": "v43",
  "latest_manifest_version": "v43",
  "is_up_to_date": true,
  "last_seen_at": "2024-01-15T14:30:00Z",
  "last_sync_at": "2024-01-15T14:30:00Z",
  "assigned_content": {
    "language": "English",
    "regions": ["East Region"],
    "providers": ["Health Ministry", "WHO"],
    "topics_count": 12,
    "tags_count": 8,
    "files_count": 47,
    "total_size": "156 MB"
  }
}
```

---

### 8. API Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/devices/me/manifest` | Get full manifest for device |
| HEAD | `/api/v1/devices/me/manifest` | Check if manifest changed (ETag) |
| GET | `/api/v1/files/{id}` | Download file (supports Range header) |
| POST | `/api/v1/devices/me/sync-status` | Report device sync status |

---

### 9. Security Considerations

- API keys can be revoked from SkillRx admin panel
- All endpoints require HTTPS
- API keys should be stored securely on device (encrypted at rest)
- File downloads validate checksum to prevent tampering
