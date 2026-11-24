# SkillRx design system

SkillRx is migrating onto the [Ruby For Good design system](https://github.com/rubyforgood/designsystem).
**Its [`design.md`](https://github.com/rubyforgood/designsystem/blob/main/design.md) is the normative
spec.** This file only records what that spec leaves to each app: SkillRx's **Local** answers (brand
color, navigation, its own screens), plus anything SkillRx does differently, and why.

If neither document answers a question, that's the finding: the rule is written down here (or
upstream, if it holds for any app) before the code changes.

## What this app is, and what the UI has to do

SkillRx is a content management system for medical training material. Administrators and
contributors manage **topics** (titles, descriptions, documents, tags, a language and a provider),
which are synced to **beacons**: offline devices in the field that serve the content to health
workers without an internet connection.

- **Two audiences.** Administrators (`users.is_admin`) see everything. Contributors see Topics and
  Beacons; the six admin areas redirect them to Topics (measured 2026-11-24 by visiting every screen
  as each role, `bin/design/targets.js`).
- **Signed-in screens are the product.** The public home page (`/`) and the sign-in page are
  marketing and entry points, styled separately today.
- **Data entry is the main work:** filtering long topic lists, editing topics, uploading documents.

## Status

Migration started 2026-11-24 on branch `skillsrxdesign`. Nothing is migrated yet.

Baseline, measured 2026-11-24 before any change:

| | |
| --- | --- |
| Screens | 28, from `bin/rails runner bin/design/route-targets.rb` |
| Templates | 69 `.erb` files under `app/views` |
| Hand-written CSS | 648 lines: `app/assets/tailwind/` (576) and `app/assets/stylesheets/` (72) |
| WCAG audit | `bin/design/wcag-audit.js`, exit 1. Results in the change log |
| Specs (non-system) | 464 examples, 1 failure, already failing at the branch point |
| System specs | 52 examples. They don't run on this machine (Selenium can't drive Chrome 158 here), but they pass in CI on `main` |

## Foundations

All from the global spec unless listed here.

### Color

*Pending, see the shell preview.* Proposed: brand scale from the SkillRx logo blue `#055889`
(7.6:1 on white).

### Typography

Figtree, the design system's typeface, self-hosted.

## App shell

*Pending, see `previews/shell.html`.*

## Screens

*Each screen is migrated after its preview is chosen. Listed here as they are.*

## Not migrated

*What is deliberately left as it is, and why. Every entry needs a reason.*

## Decisions that are not obvious

See [`decisions.md`](decisions.md).
