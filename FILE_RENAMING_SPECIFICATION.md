# File Renaming Specification: Align SkillRx/S3 Filenames with Azure

**Date:** October 25, 2025
**Status:** Specification
**Goal:** Achieve filename parity between SkillRx/S3 and Azure File Shares

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Solution Architecture](#solution-architecture)
3. [Component 1: Blob Renaming Service](#component-1-blob-renaming-service)
4. [Component 2: Lifecycle Integration](#component-2-lifecycle-integration)
5. [Component 3: One-Time Data Migration](#component-3-one-time-data-migration)
6. [Testing Strategy](#testing-strategy)
7. [Rollout Plan](#rollout-plan)
8. [Success Criteria](#success-criteria)
9. [Files to Create/Modify](#files-to-createmodify)
10. [Key Design Decisions](#key-design-decisions)
11. [Monitoring & Validation](#monitoring--validation)

---

## Problem Statement

### Current State

- Files are uploaded to SkillRx with an internal prefix: `[skillrx_internal_upload]_[filename].[ext]`
- This prefix is necessary because uploads happen before the topic is saved (no topic_id available yet)
- Files are stored in ActiveStorage/S3 with this internal prefix
- When syncing to Azure, filenames are calculated using `Topic#custom_file_name` which produces: `[topic.doc_prefix]_[provider_prefix]_[year]_[month]_[filename].[ext]`
- **Result:** Azure has the "correct" name, but S3/ActiveStorage keeps the internal prefix

### Desired State

- SkillRx/S3 filenames should match Azure filenames exactly
- **Azure is the source of truth** - we are achieving parity with what's already in Azure
- Pattern: `[topic.doc_prefix]_[provider_prefix]_[year]_[month]_[filename].[ext]`
- Example: `123_who_guidelines_2025_3_diabetes-guide.pdf`
- No changes to Azure files (they already have the correct names)

### Core Principles

1. **Rename once, when files are first attached to a topic**
2. **Never rename on topic updates** - maintains parity with Azure
3. **No rollback needed** - Azure is our source of truth
4. **Azure files remain unchanged** - we're syncing to them, not changing them

---

## Solution Architecture

### Overview

The solution consists of three main components:

1. **Service Class** - Reusable logic for renaming ActiveStorage blobs
2. **Lifecycle Integration** - Automatically rename blobs after topic creation (not updates)
3. **One-time Data Migration** - Rename all existing blobs with the internal prefix

---

## Component 1: Blob Renaming Service

### File: `app/services/blob_renamer.rb`

**Purpose:** Encapsulate the logic for renaming ActiveStorage blobs to match Azure

```ruby
class BlobRenamer
  class << self
    # Rename a single blob's filename in the database
    # Note: This updates the metadata, not the S3 key
    def rename_blob(blob, new_filename)
      return false if blob.filename.to_s == new_filename

      old_filename = blob.filename.to_s
      blob.update!(filename: new_filename)

      Rails.logger.info(
        "Renamed blob #{blob.id}: '#{old_filename}' -> '#{new_filename}'"
      )

      true
    rescue => e
      Rails.logger.error(
        "Failed to rename blob #{blob.id}: #{e.message}"
      )
      raise
    end

    # Rename a blob for a specific topic document
    def rename_for_topic(topic, attachment)
      blob = attachment.blob
      new_filename = topic.custom_file_name(attachment)

      rename_blob(blob, new_filename)
    end

    # Check if a blob has the internal prefix
    def has_internal_prefix?(blob)
      blob.filename.to_s.start_with?(Topic::INTERNAL_FILENAME_PREFIX)
    end
  end
end
```

### Key Points

- Updates `active_storage_blobs.filename` column only
- S3 key remains unchanged (includes hash, not affected)
- Filename is what gets used for downloads and Azure sync
- Idempotent - safe to call multiple times

### Why Update Filename Instead of S3 Key?

**ActiveStorage Architecture:**
- `blob.key` - The S3 object key (includes hash: `variants/abc123/filename`)
- `blob.filename` - The original filename metadata
- `blob.content_type` - MIME type
- `blob.byte_size` - File size

**Download Behavior:**
When a user downloads a file via ActiveStorage:
1. ActiveStorage reads `blob.filename`
2. Sets `Content-Disposition: attachment; filename="[blob.filename]"`
3. Streams from S3 using `blob.key`

**Result:** Users download the file with `blob.filename`, regardless of the S3 key.

**Azure Sync Behavior:**
The `FileWorker` service reads the file from S3 and uploads to Azure using the filename from `Topic#custom_file_name`. After our changes, this will match `blob.filename`.

---

## Component 2: Lifecycle Integration

### Location: `app/services/topics/mutator.rb`

**Integration Point:** After files are attached during topic creation or update

### Modified Code

```ruby
def mutate
  # ...
  ActiveRecord::Base.transaction do
    topic.save_with_tags(params)
    attach_files(document_signed_ids)
    rename_newly_attached_documents if document_signed_ids.any?  # NEW
    shadow_delete_documents(docs_to_delete)
    sync_docs_for_topic_updates if document_signed_ids.any?
    [ :ok, topic ]
  end
end

private

def rename_newly_attached_documents
  # Only rename documents that have the internal prefix
  # This ensures we achieve parity with Azure on first attachment
  # Never rename existing documents (they're already in sync with Azure)

  new_attachments = topic.documents_attachments.last(document_signed_ids.count)

  new_attachments.each do |attachment|
    blob = attachment.blob

    # Only rename if it has the internal prefix (newly uploaded)
    if BlobRenamer.has_internal_prefix?(blob)
      BlobRenamer.rename_for_topic(topic, attachment)
    end
  end
end
```

### Why This Approach

1. ✅ Rename on initial attachment - achieves parity with Azure
2. ✅ Check for internal prefix - skip files already renamed
3. ✅ Happens before Azure sync - Azure gets correct filename immediately
4. ✅ Within transaction - rollback if rename fails
5. ✅ Topic has all needed data (ID, provider, dates)

### What About Topic Updates?

- If user updates topic metadata (provider, dates), we **DO NOT** rename existing blobs
- Azure already has the file with its original name
- Renaming would break parity with Azure
- New files attached during update will be renamed with current topic data

### Edge Cases Handled

- Files without internal prefix are skipped (already correctly named or from other sources)
- Shadow copies go through same rename process (they're temporary anyway)
- Empty attachments list is skipped by the `if document_signed_ids.any?` guard

---

## Component 3: One-Time Data Migration

### File: `db/migrate/YYYYMMDDHHMMSS_rename_document_blobs_to_match_azure.rb`

**Purpose:** Rename all existing blobs that have the internal prefix to match their names in Azure

### Implementation

```ruby
class RenameDocumentBlobsToMatchAzure < ActiveRecord::Migration[8.0]
  def up
    say "Starting blob filename migration to match Azure..."

    renamed_count = 0
    skipped_count = 0
    error_count = 0

    # Process all topics (including shadow copies - they're temporary anyway)
    Topic.unscoped.find_each do |topic|
      next unless topic.documents.attached?

      topic.documents_attachments.each do |attachment|
        blob = attachment.blob

        # Only rename blobs with internal prefix
        if BlobRenamer.has_internal_prefix?(blob)
          begin
            if BlobRenamer.rename_for_topic(topic, attachment)
              renamed_count += 1
            else
              skipped_count += 1  # Already had correct name
            end
          rescue => e
            say "Failed to rename blob #{blob.id}: #{e.message}", true
            error_count += 1
          end
        else
          skipped_count += 1
        end
      end

      # Progress indicator every 100 topics
      say "Processed #{renamed_count + skipped_count} blobs..." if (renamed_count + skipped_count) % 100 == 0
    end

    say "Migration complete:"
    say "  - #{renamed_count} blobs renamed"
    say "  - #{skipped_count} blobs skipped (already correct)"
    say "  - #{error_count} errors"

    if error_count > 0
      say "WARNING: #{error_count} blobs failed to rename. Check logs for details.", true
    end
  end

  def down
    # No-op: Cannot reverse rename
    # Azure files are the source of truth, so there's no need to rollback
    say "This migration cannot be reversed. Azure files remain unchanged."
  end
end
```

### Why `Topic.unscoped`

- Default scope excludes shadow copies (`where(shadow_copy: false)`)
- Shadow copies are temporary, but might have documents
- Processing them doesn't hurt (they'll be deleted soon anyway)
- Ensures complete coverage

### Safety Features

- Batched processing with `find_each` (default 1000 records)
- Progress indicators
- Error handling that doesn't stop migration
- Detailed logging
- Idempotent (safe to run multiple times)

---

## Testing Strategy

### Unit Tests: `spec/services/blob_renamer_spec.rb`

```ruby
RSpec.describe BlobRenamer do
  let(:topic) { create(:topic, published_at: Date.new(2025, 3, 15)) }
  let(:blob) { create(:blob, filename: "[skillrx_internal_upload]_diabetes-guide.pdf") }
  let(:attachment) { create(:attachment, blob: blob, record: topic) }

  describe '.rename_blob' do
    it 'updates blob filename' do
      BlobRenamer.rename_blob(blob, "new_name.pdf")
      expect(blob.reload.filename.to_s).to eq("new_name.pdf")
    end

    it 'logs the change' do
      expect(Rails.logger).to receive(:info).with(/Renamed blob/)
      BlobRenamer.rename_blob(blob, "new_name.pdf")
    end

    it 'returns false if filename is already correct' do
      result = BlobRenamer.rename_blob(blob, blob.filename.to_s)
      expect(result).to be false
    end

    it 'raises error on failure' do
      allow(blob).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      expect { BlobRenamer.rename_blob(blob, "new.pdf") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.rename_for_topic' do
    it 'renames blob to match topic custom filename' do
      BlobRenamer.rename_for_topic(topic, attachment)

      expected = "#{topic.id}_#{topic.provider.name.parameterize(separator: '_')}_2025_3_diabetes-guide.pdf"
      expect(blob.reload.filename.to_s).to eq(expected)
    end
  end

  describe '.has_internal_prefix?' do
    it 'returns true for blobs with internal prefix' do
      expect(BlobRenamer.has_internal_prefix?(blob)).to be true
    end

    it 'returns false for properly named blobs' do
      blob.update(filename: "123_provider_2025_3_file.pdf")
      expect(BlobRenamer.has_internal_prefix?(blob)).to be false
    end
  end
end
```

### Integration Tests: `spec/services/topics/mutator_spec.rb`

```ruby
describe Topics::Mutator do
  describe '#create' do
    context 'when creating topic with uploaded documents' do
      let(:blob) { create(:blob, filename: "[skillrx_internal_upload]_test.pdf") }
      let(:signed_id) { blob.signed_id }

      it 'renames uploaded documents after attachment' do
        mutator = Topics::Mutator.new(
          topic: build(:topic),
          params: topic_params,
          document_signed_ids: [signed_id]
        )

        mutator.create

        expect(blob.reload.filename.to_s).not_to include("[skillrx_internal_upload]")
        expect(blob.filename.to_s).to match(/^\d+_.*\.pdf$/)
      end

      it 'does not rename documents without internal prefix' do
        blob.update(filename: "already_named.pdf")

        mutator = Topics::Mutator.new(
          topic: build(:topic),
          params: topic_params,
          document_signed_ids: [signed_id]
        )

        expect { mutator.create }.not_to change { blob.reload.filename.to_s }
      end
    end
  end

  describe '#update' do
    context 'when adding new documents to existing topic' do
      let(:topic) { create(:topic, :with_documents) }
      let(:existing_blob) { topic.documents.first }
      let(:new_blob) { create(:blob, filename: "[skillrx_internal_upload]_new.pdf") }

      it 'only renames newly attached documents' do
        original_filename = existing_blob.filename.to_s

        mutator = Topics::Mutator.new(
          topic: topic,
          params: {},
          document_signed_ids: [new_blob.signed_id]
        )

        mutator.update

        # Existing blob unchanged
        expect(existing_blob.reload.filename.to_s).to eq(original_filename)

        # New blob renamed
        expect(new_blob.reload.filename.to_s).not_to include("[skillrx_internal_upload]")
      end
    end

    context 'when updating topic metadata' do
      let(:topic) { create(:topic, :with_documents) }

      it 'does not rename existing documents' do
        original_filename = topic.documents.first.filename.to_s

        mutator = Topics::Mutator.new(
          topic: topic,
          params: { provider_id: create(:provider).id },
          document_signed_ids: []
        )

        mutator.update

        # Existing documents not renamed despite provider change
        expect(topic.documents.first.reload.filename.to_s).to eq(original_filename)
      end
    end
  end
end
```

### Migration Test: Manual Verification

**Before deploying to production:**

```ruby
# In Rails console on staging/production copy:

# 1. Count blobs with internal prefix
prefixed_blobs = ActiveStorage::Blob
  .joins(:attachments)
  .where("active_storage_blobs.filename LIKE ?", "[skillrx_internal_upload]%")
  .distinct

puts "Found #{prefixed_blobs.count} blobs with internal prefix"

# 2. Run migration
# db:migrate

# 3. Verify no internal prefixes remain
remaining = ActiveStorage::Blob
  .joins(:attachments)
  .where("active_storage_blobs.filename LIKE ?", "[skillrx_internal_upload]%")
  .distinct

puts "Remaining blobs with internal prefix: #{remaining.count}"
raise "Migration incomplete!" if remaining.count > 0

# 4. Spot check 10 random topics
Topic.where.not(id: Topic.where(shadow_copy: true).select(:id))
     .joins(:documents_attachments)
     .distinct
     .order("RANDOM()")
     .limit(10)
     .each do |topic|
  topic.documents_attachments.each do |att|
    expected = topic.custom_file_name(att)
    actual = att.blob.filename.to_s
    puts "Topic #{topic.id}: #{actual == expected ? '✓' : '✗'} #{actual}"
  end
end
```

---

## Rollout Plan

### Phase 1: Development & Testing (Week 1)

1. Implement `BlobRenamer` service
2. Add comprehensive unit tests
3. Test locally with development data

### Phase 2: Lifecycle Integration (Week 1-2)

1. Modify `Topics::Mutator#rename_newly_attached_documents`
2. Add integration tests for create and update
3. **Verify update does NOT rename existing documents**
4. Test full topic creation/update flow

### Phase 3: Migration Preparation (Week 2)

1. Write data migration
2. Test on production database copy
3. Verify migration is idempotent
4. Document expected counts and timing

### Phase 4: Deploy Code Without Migration (Week 3)

1. Deploy code with lifecycle integration
2. Verify new uploads get renamed correctly
3. Verify topic updates don't rename existing files
4. Monitor for issues
5. Let run for a few days to ensure stability

### Phase 5: Migration Execution (Week 3-4)

1. Count blobs needing rename in production
2. Schedule migration during low-traffic window
3. Run migration on production
4. Monitor migration progress logs
5. Verify zero blobs with internal prefix remain

### Phase 6: Validation (Week 4)

1. Spot-check 50 random topics
2. Verify filenames match pattern
3. Test file downloads have correct names
4. Verify Azure sync continues to work
5. Monitor error logs for 1 week

---

## Success Criteria

### Code Deployment Success

- [ ] New uploads are renamed after topic save
- [ ] Topic updates do NOT rename existing documents
- [ ] Renamed files match Azure filename pattern
- [ ] No internal prefix in new blobs
- [ ] Azure sync continues to work
- [ ] File downloads have correct names

### Migration Success

- [ ] 100% of blobs with internal prefix are renamed
- [ ] Zero blobs with internal prefix remain
- [ ] No errors during migration
- [ ] Spot-check confirms correct naming pattern
- [ ] Azure sync still works for all files

### Long-term Success

- [ ] **Parity achieved**: S3 filenames match Azure filenames
- [ ] No confusion about file naming
- [ ] Easier debugging (consistent names everywhere)
- [ ] Downloads have meaningful names
- [ ] Topic metadata changes don't break parity

---

## Files to Create/Modify

### New Files

1. `app/services/blob_renamer.rb` - Renaming service
2. `spec/services/blob_renamer_spec.rb` - Service tests
3. `db/migrate/YYYYMMDDHHMMSS_rename_document_blobs_to_match_azure.rb` - Migration

### Modified Files

1. `app/services/topics/mutator.rb` - Add `rename_newly_attached_documents` method
2. `spec/services/topics/mutator_spec.rb` - Add rename tests (create and update)
3. `spec/requests/topics/create_spec.rb` - Add integration tests
4. `spec/requests/topics/update_spec.rb` - Verify no rename on update

---

## Key Design Decisions

### ✅ Rename on create, NOT on update

**Rationale:** Azure is the source of truth. Files already in Azure have their "correct" names based on the topic data at the time of upload. Renaming on update would break parity.

### ✅ No need to store original filename

**Rationale:** Azure has the files. If we ever need to recover, Azure is our backup. We're not creating new names, we're achieving parity with existing names.

### ✅ Only rename blobs with internal prefix

**Rationale:** Idempotent. Safe to run multiple times. Skips files that were uploaded through other means or already renamed.

### ✅ Rename before Azure sync

**Rationale:** Ensures Azure sync uses the correct filename immediately. No window where names don't match.

### ✅ Within transaction

**Rationale:** If rename fails, entire topic create/update rolls back. Prevents partial state.

---

## Monitoring & Validation

### What to Monitor After Deployment

**1. Application Logs:**

```bash
grep "Renamed blob" production.log | wc -l  # Count of renames
grep "Failed to rename blob" production.log  # Any failures
```

**2. Database Queries:**

```ruby
# Count blobs with internal prefix (should decrease over time)
ActiveStorage::Blob
  .where("filename LIKE ?", "[skillrx_internal_upload]%")
  .count
```

**3. Azure Sync Errors:**

```bash
grep "FileWorker" production.log | grep -i error
```

**4. Download Tests:**

- Download a few recently created topic documents
- Verify filename matches expected pattern
- No internal prefix in downloaded name

### Red Flags

- ❌ Internal prefix appears in new uploads after deployment
- ❌ Azure sync errors increase
- ❌ Download filenames still show internal prefix
- ❌ Migration shows high error count

---

## Current Filename Convention Reference

From `app/models/topic.rb` (lines 71-82):

```ruby
# naming convention described here: https://github.com/rubyforgood/skillrx/issues/305
# [topic.id]_[provider.provider_name_for_file.parameterize]_[topic.published_at_year]_[topic.published_at_month][document_filename.parameterize].[document_extension]
def custom_file_name(document)
  topic_data = [
    doc_prefix,
    provider.file_name_prefix.present? ? provider.file_name_prefix.parameterize : provider.name.parameterize(separator: "_"),
    published_at_year,
    published_at_month,
  ].compact.join("_")

  document.filename.to_s.sub(INTERNAL_FILENAME_PREFIX, topic_data)
end
```

**Example:**
- Topic ID: 123
- Provider name: "WHO Guidelines"
- Published: 2025-03-15
- Original file: "diabetes-guide.pdf"

**Result:** `123_who_guidelines_2025_3_diabetes-guide.pdf`

---

## Questions?

For questions or clarifications about this specification, please contact the development team.
