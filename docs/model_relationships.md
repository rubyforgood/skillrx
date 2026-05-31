# Model Relationships

_(A Draft of v3 Architecture, helpful for me to understand and also to onboard others)_

## The big picture

SkillRx delivers continuing medical education (CME) to medical practitioners in remote areas. Understanding that mission makes the model hierarchy intuitive.

**Topic is the protagonist.** A Topic is the actual CME content — the reason the app exists. Everything else exists to produce Topics, organize them, or get the right ones to the right place.

**Provider is the author.** A Provider (an NGO, hospital system, or medical publisher) produces Topics in a given Language. Without Providers there is no content; without content there is no app.

**Beacon is the delivery hero.** A Beacon represents a physical deployment — a device or installation at a remote clinic. It is configured for a specific Language and Region, and acts as a gatekeeper: filtering which Topics (and from which Providers) that location can access.

The narrative arc of the data:

> A **Provider** produces **Topics** (CME materials) in a given **Language**. A **Beacon** is deployed at a remote clinic — configured for a specific **Region** and **Language** — and serves as the gatekeeper that filters which **Topics** (and from which **Providers**) that clinic's device can access.

---

## 1. Content layer

_What the app exists to deliver._

### Topic

The central domain object. Every other model either produces, organizes, or delivers Topics.

- Belongs to one **Language**
- Belongs to one **Provider**
- Has many **Beacons** through BeaconTopics (which beacons serve this topic)
- Has many **Tags** via `acts_as_taggable_on` (for search and discoverability)

### Provider

The organization that authors content.

- Has many **Topics** (a topic belongs to exactly one provider)
- Has many **Branches** → and through them, many **Regions** (a provider can operate in multiple regions)
- Has many **Contributors** → and through them, many **Users** (the people who manage that provider's content)
- Has many **Beacons** through BeaconProviders

### Language

The language a Topic is written in; also used to scope a Beacon's content.

- Has many **Topics**
- Has many **Providers** through Topics (derived: which providers have content in this language)
- Has many **Beacons** (each beacon is assigned exactly one language)

---

## 2. Delivery layer

_How content reaches remote locations._

### Beacon

The delivery object through which medical practitioners access topics. It's managed by **Provider(s)** to deliver **Topics** to end users.

- Belongs to one **Language** (required — scopes topics to one language)
- Belongs to one **Region** (required — scopes providers to those with a branch in this region)
- Has many **Providers** through BeaconProviders (optional further restriction)
- Has many **Topics** through BeaconTopics (optional further restriction)

### Region

The geographic area a Beacon serves; also how Providers are scoped to locations.

- Has many **Branches** (a branch is a provider's presence in a region)
- Has many **Providers** through Branches
- Has many **Beacons** (each beacon is assigned exactly one region)

### Branch

Links a Provider to a Region. The join that makes geographic filtering possible.

- Belongs to one **Provider**
- Belongs to one **Region**

---

## 3. People layer

_Who manages the content._

### User

An administrator of the system.

- Has many **Contributors** → and through them, many **Providers**
- Non-admin users must be affiliated with at least one Provider (enforced by model validation)
- Admins have no provider requirement

### Contributor

Records a User's affiliation with a Provider.

- Belongs to one **User**
- Belongs to one **Provider**

---

## 4. Taxonomy layer

_How content is discovered and grouped._

### Tag

A keyword applied to Topics to support search and filtering.

- Applied to Topics via `acts_as_taggable_on`
- Can be linked to other Tags as **cognates** (semantically equivalent terms — e.g. synonyms across dialects or languages)

### TagCognate

A self-referential join between two Tags that are considered cognates. Relationships are deduplicated (no reverse duplicates allowed). When a tag is added to a topic, its cognates are automatically added as well.

- Belongs to one **Tag** (as `tag`)
- Belongs to one **Tag** (as `cognate`)

---

## Join / pivot model summary

| Model              | Joins                        | Layer    |
| ------------------ | ---------------------------- | -------- |
| **Branch**         | Provider ↔ Region            | Delivery |
| **Contributor**    | User ↔ Provider              | People   |
| **BeaconProvider** | Beacon ↔ Provider            | Delivery |
| **BeaconTopic**    | Beacon ↔ Topic               | Delivery |
| **TagCognate**     | Tag ↔ Tag (self-referential) | Taxonomy |

---

## Diagram

```
[People]
User ──── Contributor ──────────────────────────┐
                                                 ↓
[Content]                               Provider ──── Branch ──── Region
Language ──── Topic ───────────────────────↑                        ↑
                │                                                   │
              [Tag] ── TagCognate                                   │
                                                                    │
[Delivery]                            Beacon ──────────────────────┘
                          (belongs_to Language, Region)
                          (has_many Providers via BeaconProvider)
                          (has_many Topics via BeaconTopic)
```
