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

Current version: **0.1.8** (upgraded 2026-11-27). To upgrade, change the version in the URL in each file's header and
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
- **No icons** (decided 2026-11-25). With three top-level entries there is nothing for an icon to
  help you scan, and icons on Topics and Beacons said little the word didn't. Hierarchy comes from
  type and indent: top level 15px medium, Administration's items 14px regular, indented 14px past
  the parent's text. Global design.md's rule 1 ("icons on exactly one level, never more") still
  holds: zero levels is allowed. Its Local default (icons on the top level) is the part we drop.
- **Spacing: one 2px rhythm** between every row, top level or nested, including above the
  Administration group (decided 2026-11-26: the 12px gap there read as uneven; the chevron and the
  indented items already mark it as a group). Global design.md's Local table puts 16px
  between top-level entries; that suits Human Essentials, where the top level is mostly collapsed
  groups, but between two plain links it reads as two unrelated blocks. GitHub, Linear, Stripe and
  Vercel all keep rail rows 0 to 4px apart and separate sections with a larger gap or a heading.
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

## Buttons

From the design system's "Buttons" and "Where a button goes" (decided there, applied here 2026-11-25).
Checked on every screen by `bin/design/button-audit.js` (page headers) and
`bin/design/button-rules-audit.js` (everything else).

| Variant | Class | Looks like | Use for |
| --- | --- | --- | --- |
| Primary | `.button-primary` | Filled brand blue | The one action a page or form is for: Add a topic, Save topic |
| Secondary | `.button-secondary` | White, gray border | Every other action: Edit, Archive, Regenerate key |
| Ghost | `.button-ghost` | No border, tinted on hover | Row actions, Cancel, Clear filters |
| Ghost danger | `.button-ghost-danger` | Gray at rest, **red on hover and focus** | Delete, Remove, Revoke: anywhere they appear |
| Danger | `.button-danger` | Filled red | **Only** the button that carries out a destruction, inside its confirmation |

**Why Delete isn't red until you point at it.** A destructive button that's red at rest shouts, and
down a table it shouts on every row, saying nothing the word doesn't already say. What protects
people is the confirmation, not the color: every Delete asks first, and the button that actually
deletes, in that confirmation, is filled red. (The design system: "a repeated destructive control
shouldn't shout at rest".)

Placement:
- **Page header, right-aligned: the primary goes last.** At most three actions and one primary.
- **Record pages have no primary** (their job is to be read): Delete first, then other actions, Edit
  last, as secondary. A destructive action never takes the last slot, where the main action belongs.
- **Form actions, left-aligned: the primary goes first.** `[Save topic] Cancel`.
- **Row actions are ghost and small** (32px); everything else is 40px, the same height as a field.
- **Anything that changes data is a button in a form** (`button_to`), never a link.

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
  the list's Turbo frame. One row: the always-visible fields (`search` slot: Search, and Topics'
  Provider), then "Filters" (three or more filters fold behind it, and it starts open when one is
  set), then Clear filters, then **Sort at the far end** (`end` slot). Opening Filters never moves
  the row; the panel opens below it from the left edge (design system 0.1.7).
- **Sort is not a filter** (decided 2026-11-26): it changes the order, not which records are listed.
  So it never folds, and **Clear filters keeps it**. On Topics, Tags and Users. Tags, left with only
  Search, has no Clear filters: the search box has its own ×.
- **Clear filters is a submit button** (`name="clear"`, `data-turbo-frame="_top"`), not a link: a
  link's address is drawn with the page, and changing Sort reloads only the list, so a link sent
  the old sort. The controller redirects to the list with the sort kept and the filters dropped
  (`redirect_clearing_filters`).
- **Sort options say the order:** "Newest first", "Oldest first"; on Tags also "Name (A–Z)",
  "Most used", "Least used" (were "Highest number of taggings", "By most recently added" and so on).
- **Filter options say what they mean:** "Any language", month names, "Newest first". A select's
  first option is its default. Option values are strings, to match the URL.
- **Write slotted elements as plain HTML**, not `link_to`: in development Herb wraps ERB output in a
  `<span>`, and a slotted element must be the component's direct child.
- **Tables:** `<rfg-table>` around a `<table class="data-table">` with a caption (visually hidden
  when the heading already says it), `<th scope="row">` for the name, `.numeric` for counts. 16px
  from the panel's edges to the first and last column. `<rfg-table>` keeps a visually hidden header label
  inside the table (design system 0.1.6; before, it widened the page: 744px at a 390px viewport).
- **Below the table:** "Showing 1–25 of 42 topics" and pagy's page links, restyled.
- **Long text:** two lines, then "…" (`.clamp-2`); the full text is on the record's page.
- **No results:** "No topics match these filters", with a link to clear them.
- **Provider on Topics** (decided 2026-11-26, preview `previews/topics-provider.html`, option D): a
  filter, first in the toolbar, labeled above like the others, shown only to people with more than
  one provider. "All providers" is its first option and the default; every provider is listed,
  including the chosen one. Under All, a **Provider column** follows Title, as plain text: pills are
  for status, and an open-ended list of names can't each get a color. Choosing one provider hides
  the column (every row would say the same thing) and makes it the default on the topic form.
  - **Remembered between visits** (a cookie, as before), so the field is named `provider`, outside
    `search[…]`. **Clear filters** links with `provider=all`, resetting it like any other filter.
  - **The cookie isn't written on a Turbo prefetch**, and Clear filters has
    `data-turbo-prefetch="false"`: hovering a link must not change what's remembered. Found by a
    spec that failed when the pointer crossed Clear filters.
  - **The topics list has no Turbo preview** (`turbo-cache-control: no-preview`): a cached preview
    showed the filters from an earlier visit until the page arrived.
  - **The topic form shows Provider to anyone with more than one** (it was administrators only),
    because a contributor's new topic used to go to the provider chosen on the list, which can now be All.
    A provider outside the person's own is refused (404).

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
- <a id="error-messages"></a>**Error messages** (`config/locales/en.yml`) say what to do, in the
  form's own words, as GOV.UK and the US Web Design System advise: "Enter a title", not Rails'
  "Title can't be blank". The rules:
  - **An instruction, not a fault.** "Enter …" for a text field, "Choose …" for a select (the
    app's word, as in "Choose a provider"). For a wrong value, say what a right one looks like:
    "Enter an email address in the right format, like name@example.com".
  - **One message per problem.** A blank field gets "Enter …" only, not "blank" and "invalid" too
    (`allow_blank` on the format and length checks), and a required association is checked once
    (`belongs_to`, not also a presence check on its id).
  - **The same text in the summary and under the field**, so it's a whole sentence: each
    attribute's `format` is `"%{message}"` (`i18n_customize_full_message`). No full stop.
  - **In the form's order.** Validations run, and the summary lists them, in declaration order, so
    `Topic` and `User` declare them in the order of their fields.
  - **A select of ids shows its association's error** (`form_field` reads `:language` for
    `:language_id`), so "Choose a language" sits under Language, not only in the summary.
  - **A conditional requirement is said in the hint**, not marked: Providers on the user form is
    "Required unless they're an administrator."
  - **US English, sentence case, contractions** ("can't", "don't"), as in the rest of the app.
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

- **A subtitle earns its place by saying something the heading doesn't** that you need right now,
  such as what happens next ("You'll get its API key after you save. It's shown only once."). A description of what the page
  is ("Educational topics and the documents in them") is dropped. Edit pages keep the record's name.
- **A field hint says only what you need to fill it in:** a format or example ("For example,
  Kampala central clinic."), a limit ("Up to 72 characters."), or a consequence ("With none chosen,
  the beacon has no content."). A hint that restates the label is dropped.
- **An empty state says what to do next** ("Add a provider before adding topics."), not what the
  page is for.
- **Every claim is checked against the code.** The sweep found two false ones carried over from
  before the migration: "Minimum 8 characters" (no such validation) and "leave blank for all
  providers/topics" (a beacon gets only what's chosen on it; `Beacons::ManifestBuilder`).

## Jobs

**In the app shell** (decided 2026-11-26; it was the one admin page left in its own look, in a new
tab). Mission Control Jobs is a gem with its own views, so the rule is: override as little as
possible, style the rest.

- **Overridden** (diff these on a gem upgrade): `layouts/mission_control/jobs/application.html.erb`
  (renders inside `layouts/application` through `content_for :shell_content`), `_navigation`,
  `_flash`, `_application_selection` beside it, and the six partials that hold buttons under
  `app/views/mission_control/jobs/` (the action partials, `_toolbar`, `_filters`).
- **Styled, not overridden:** every other engine template. `components/jobs.css` gives the Bulma
  class names they use the app's look (tables, status tags as pills, headings, fields, pagination),
  scoped to `.jobs-engine`. Bulma and the engine's importmap aren't loaded; the engine's one Stimulus
  controller (`form`, filters submit on change) is in `app/javascript/controllers`.
- **Sections are `<rfg-page-tabs>`**, in sentence case ("In progress jobs", not "In Progress").
  They scroll sideways on a phone.
- **Buttons:** row actions (Retry, Run now, Pause) are ghost at 32px and Discard is ghost-danger, as
  in every other table; on a job's page the action is secondary at 40px (`JobsHelper`). Discards
  confirm in the app's dialog.
- **The shell's links use `shell_path(:name)`**: inside the engine, route helpers are the engine's,
  and its `default_url_options` add `?server_id=` to every URL, `main_app`'s too.
- **Audited:** `bin/design/route-targets.rb` lists the engine's list screens, so the WCAG and button
  audits visit them as an administrator.

## Not migrated

What is deliberately left as it is, and why.

| What | Why |
| --- | --- |
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
