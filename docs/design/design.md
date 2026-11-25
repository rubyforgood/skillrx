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

Migration started 2026-11-24 on branch `skillsrxdesign`. **Every screen is migrated** (2026-11-25): app
shell, sign-in and password pages, home page, Topics, Beacons, Providers, Regions, Languages, Tags,
Users, Import reports, and the static error pages. See "Not migrated" for what's deliberately left.

After, measured 2026-11-25:

| | |
| --- | --- |
| WCAG audit | `bin/design/wcag-audit.js`: **0 violations, 36 pages** (was 4 kinds on 83 elements) |
| Every screen, both roles, at 390px | 42 visits: no sideways scroll, no template errors, no N+1 warnings, no old classes |
| Specs | 514 examples, 0 failures |
| Hand-written CSS | 69 unused legacy rules and `animations.css` removed |

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

Current version: **0.1.5** (upgraded 2026-11-25). To upgrade, change the version in the URL in each file's header and
download again. Don't edit them by hand: SkillRx-specific values go in `application.css`.

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

## Row actions

The rule for every table (decided 2026-11-25, see decisions.md):

- **The first column's name links to the record.** No separate View button.
- **Up to two settled actions stay visible** as small ghost buttons (`.button .button-ghost
  .button-sm`) at the end of the row, each named for its row (`aria-label="Edit <title>"`).
- **Three or more on any row, or a set that varies by state or role:** a ⋯ menu (`<rfg-menu>`) on
  every row of that table.
- **Archiving and deleting** happen on the record's own page unless a list needs them; deleting is
  confirmed in the app's own dialog, not the browser's `confirm()`.

## Lists and filters

- **Page header:** `shared/_page_header` (server-rendered: `<rfg-page-header>` draws its `<h1>` only
  after JavaScript runs, so the heading would arrive late and push the page down). One primary
  action, sentence case.
- **Filters:** `<rfg-filter-bar>` inside the list's `form_for`, so its controls keep submitting into
  the list's Turbo frame. Search goes in the `search` slot and stays visible; three or more other
  filters fold behind "Filters", which starts open when one is set.
- **Filter options say what they mean:** "Any language", month names, "Newest first". A select's
  first option is its default. Option values are strings, to match the URL.
- **Write slotted elements as plain HTML**, not `link_to`: in development Herb wraps ERB output in a
  `<span>`, and a slotted element must be the component's direct child.
- **Tables:** `<rfg-table>` around a `<table class="data-table">` with a caption (visually hidden
  when the heading already says it), `<th scope="row">` for the name, `.numeric` for counts. 16px
  from the panel's edges to the first and last column. `rfg-table` is `position: relative`, so a
  visually hidden header label can't widen the page (it did: 744px at a 390px viewport).
- **Below the table:** "Showing 1–25 of 42 topics" and pagy's page links, restyled.
- **Long text:** two lines, then "…" (`.clamp-2`); the full text is on the record's page.
- **No results:** "No topics match these filters", with a link to clear them.

## Forms, record pages and confirmation

- **Fields:** `form_field f, :attr, label:, required:, optional:, hint:` (`app/helpers/form_helper.rb`)
  renders the label, a red `*` (`<abbr title="required">`) or "(optional)", the hint, the control and
  its error, wired with `aria-describedby`, `aria-invalid` and `aria-required`. Server-rendered, so
  labels never wait for JavaScript. It fixed the topic form's year and month labels, which pointed at
  ids that didn't exist (the audit's "select has no accessible name").
- **Layout:** a white panel (`.surface`) holding `.form-card` sections, each with an `h2`; two-column
  `.form-grid` for short fields; actions in `.form-actions` at the bottom: the primary button first,
  then Cancel.
- **Errors:** `shared/_errors`, at the top of the form, `role="alert"`: "Fix these 2 problems to save
  the topic" and the list; each field shows its own message too.
- **Messages after an action** (`shared/_flash`): `<rfg-callout>` at the top of the page, success or
  danger.
- **Record pages:** page header with the actions (primary Edit first, then secondary, then a quiet
  red Delete), a "Back to …" link, then panels; details in a `<dl class="details">`.
- **Confirming:** every `data-turbo-confirm` opens the app's own dialog (`shared/_confirm_dialog`,
  `confirm_dialog.js`), never the browser's `confirm()`. Cancel has focus. Topics and tags keep their
  two-step delete, now an `.inline-confirm` panel in place of the button.
- **Red text** uses the 700 step (`rose-700`): `--color-danger` (600) is for fills.
- **TomSelect** (the tags fields) uses the same border, focus outline and chips as everything else.

## Screens

*Each screen is migrated after its preview is chosen. Listed here as they are.*

## Subtitles and helper text

Asked 2026-11-25: "make them more utilitarian and plain language." The rule:

- **A subtitle earns its place by saying something the heading doesn't** that you need right now:
  which provider's topics you're looking at ("From Community health clinic"), or what happens next
  ("You'll get its API key after you save. It's shown only once."). A description of what the page
  is ("Educational topics and the documents in them") is dropped. Edit pages keep the record's name.
- **A field hint says only what you need to fill it in:** a format or example ("For example,
  Kampala central clinic."), a limit ("Up to 72 characters."), or a consequence ("With none chosen,
  the beacon has no content."). A hint that restates the label is dropped.
- **An empty state says what to do next** ("Add a provider before adding topics."), not what the
  page is for.
- **Every claim is checked against the code.** The sweep found two false ones carried over from
  before the migration: "Minimum 8 characters" (no such validation) and "leave blank for all
  providers/topics" (a beacon gets only what's chosen on it; `Beacons::ManifestBuilder`).

## Not migrated

What is deliberately left as it is, and why.

| What | Why |
| --- | --- |
| **Jobs** (`/jobs`) | Mission Control's own engine UI, opened in a new tab. Restyling a gem's views means maintaining a fork of them. |
| **Emails** (`app/views/*_mailer`) | Email clients need inline styles and tables; a separate piece of work. |
| **The JSON API** (`/api/v1`) | No UI. |
| **`registrations#new`, `topics/tags#index`** | Routed, but no controller exists; both 500. For the app's maintainers (onboarding-maintainers.md). |

## Onboarding

- [Maintaining SkillRx's design](onboarding-maintainers.md): where things live, how to build a
  screen, previews, vendoring components, running the checks.
- [Guide for people using SkillRx](guide-for-users.md): what changed and where things are now.

Both are updated in the same pull request as the screens they describe.

## Decisions that are not obvious

See [`decisions.md`](decisions.md).
