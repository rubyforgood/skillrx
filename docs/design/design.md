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

Migration started 2026-11-24 on branch `skillsrxdesign`. **Done:** tokens, font, app shell, form controls, sign-in and password pages, home page. **Next:** the signed-in screens.

Baseline, measured 2026-11-24 before any change:

| | |
| --- | --- |
| Screens | 28, from `bin/rails runner bin/design/route-targets.rb` |
| Templates | 69 `.erb` files under `app/views` |
| Hand-written CSS | 648 lines: `app/assets/tailwind/` (576) and `app/assets/stylesheets/` (72) |
| WCAG audit | `bin/design/wcag-audit.js`, exit 1. Results in the change log |
| Specs | 516 examples, 0 failures (including 52 system specs) |

## Foundations

All from the global spec unless listed here.

### Color

**Local: the brand scale is the SkillRx logo blue** (decided 2026-11-24, see decisions.md).
Defined in `app/assets/tailwind/application.css`, overriding the design system's default indigo:

| Token | Value | Contrast |
| --- | --- | --- |
| `--color-brand-50` | `#eef6fb` | background for current nav item |
| `--color-brand-100` | `#d5e8f4` | |
| `--color-brand-600` | `#055889` | 7.6:1 on white |
| `--color-brand-700` | `#044a72` | 9.4:1 on white, 8.6:1 on brand-50 |

Everything else (neutrals, success, warning, danger, info) is the design system's default.

### Typography

Figtree, the design system's typeface, self-hosted from `app/assets/fonts/figtree/` (SIL Open Font
License). Latin subset, weights 400, 500, 600 and 700.

## Design system files

Vendored at a pinned version, never loaded from a CDN at runtime:

| File | From |
| --- | --- |
| `app/assets/tailwind/rfg-theme.css` | `tokens/theme.css`, imported with `theme(static)` so every token is emitted (the components read them as CSS variables) |
| `vendor/javascript/rfg-*.js` | `dist/standalone/<name>.mjs`, pinned in `config/importmap.rb`, imported in `application.js` |

Current version: **0.1.3**. To upgrade, change the version in the URL in each file's header and
download again. Don't edit them by hand: SkillRx-specific values go in `application.css`.

One local workaround: `--radius-pill` is overridden in `application.css`, because v0.1.3's
`theme.css` points it at a Tailwind variable that doesn't exist (pills and avatars were square).
Fixed upstream in rubyforgood/designsystem `cc75653`; remove the override on the next upgrade.

## App shell

**Grouped rail** (option A, decided 2026-11-24). `layouts/application.html.erb`,
`layouts/_sidebar.html.erb`, `controllers/shell_controller.js`,
`app/assets/tailwind/components/sidebar.css`. Follows the global design.md's "Sidebar rules".

- **At `lg` (1024px) and up:** fixed 256px rail on the left. **Below `lg`:** a top bar with the logo
  and a menu button that opens the rail as a drawer. Escape or the backdrop closes it; focus moves
  into it on open and back to the button on close.
- **Order:** Topics, Beacons, Administration (Providers, Regions, Languages, Tags, Users, Import
  reports, Jobs). Contributors see Topics only. Same information architecture as before the
  migration.
- **Icons on the top level only**; Administration's items are indented, without icons.
- **The current page** is marked with `aria-current="page"` by `nav_link_to`, for its own path and
  everything under it (`/topics/3/edit` marks Topics).
- **Administration starts open**, as in the chosen preview, and can be collapsed. It's the only
  group, and its seven items fit without scrolling, so collapsing it by default would only add a
  click to every admin task. (Human Essentials collapses its groups because it has four, holding 34
  items.)
- **Account strip at the bottom:** avatar, email, role, and an account menu holding **Sign out**.
  Signing out is not destructive, so it isn't red.
- **Footer:** "Built by Ruby For Good volunteers", at the end of the page, not fixed to the window.
  It shares the account strip's 64px height and top border, so the two rules meet as one line.
- **Skip link** to `#main-content`, first in the tab order.

## Forms

Every text field, select and textarea uses `.form-input`, `.form-select` or `.form-textarea`
(`app/assets/tailwind/application.css`), wrapped in `<rfg-field label="…">` for its label, required
marker and error message.

- **Border: `neutral-500`, 4.76:1 on white**, so a field's edge meets WCAG 1.4.11's 3:1 (decided
  2026-11-24). Material 3's outlined field and IBM Carbon do the same. The design system's own
  components used `neutral-200` (1.23:1); fixed upstream too.
- **Focus:** a 2px `brand-600` outline, 1px out from the border.
- **Placeholder text is not a label.** Use the label, and hint text for examples.

## Sign-in

`layouts/session.html.erb`: **a centered card** (option B, decided 2026-11-24). Logo, one card with
the form, a link back to the home page, on `neutral-50`. Follows GitHub, Stripe, Linear and
Atlassian: only people with an account sign in, so the page doesn't explain SkillRx. Used by sign
in, forgot password and choose a new password.

- **Messages** (wrong password, reset link sent) are an `<rfg-callout>` inside the card above the
  form: `danger` for problems (`role="alert"`), `success` otherwise. Not a toast in the corner, where
  someone looking at the form won't see it.
- **No "Remember me".** Every sign-in already lasts until you sign out (see decisions.md).
- **Contact:** `contact@skillrx.org`, everywhere.

## Home page

`layouts/home.html.erb`, `home/index.html.erb`: **today's sections, restyled** (option A, decided
2026-11-24). Header, hero, features, mission, contact, footer. Copy is today's, in sentence case.

- **One accent color,** the brand blue: a solid `brand-700` hero instead of the animated gradient,
  `brand-50` icon tiles instead of six colors.
- **No entrance animation.** The hero heading started at 13% opacity and took about a second to
  appear.
- **Primary actions are plain links** styled as buttons, so they work before JavaScript loads.
  "Get started today" became **Contact us**: it went to sign-in, where nobody can create an account.
- **Removed, pending verification:** the numbers section and the subject module counts (see
  decisions.md for how to restore them). "Join thousands of healthcare professionals…" is kept, by
  decision.
- **Small screens:** a menu button opens the section links (`disclosure_controller.js`); following a
  link closes it. In-page links scroll smoothly unless reduced motion is set, and land below the
  sticky header (`scroll-margin-top`).
- **Footer links have text** (GitHub, LinkedIn, Email). They were icon-only with no name, a WCAG
  failure.

## Screens

*Each screen is migrated after its preview is chosen. Listed here as they are.*

## Not migrated

*What is deliberately left as it is, and why. Every entry needs a reason.*

## Decisions that are not obvious

See [`decisions.md`](decisions.md).
