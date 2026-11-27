# Design decisions

Append-only. Newest at the bottom. A decision that turns out to be wrong gets an annotation, never
an edit, because something was built on the strength of it.

## 2026-11-24: Migrate SkillRx onto the Ruby For Good design system

Asked for: "migrate skillsrx to this design system … go through the full end to end process."

### What was actually wrong

Measured on 2026-11-24, signed in as the seeded admin:

- **Every screen has its own color.** Topics has a purple gradient banner, Users and Regions green,
  the topic form dark blue, the Users filter indigo. Buttons are blue, gray, green and red with no
  consistent meaning.
- **Text in tables wraps mid-word.** On Users, the role pills ("Contribut / or") and row buttons
  ("Vie / w", "Edi / t") break across lines at 1280px wide.
- **The nav uses emoji as icons**, and "Log out" is a red button, the color for destructive actions.
- **The Topics filter panel is 547px tall**, so on a 1280×800 screen the table starts below the fold.
- **The WCAG audit fails** (`bin/design/wcag-audit.js`, exit 1). Details in the change log.

### Is there a legacy system to retire?

No CSS framework. SkillRx is already on Tailwind v4 (`tailwindcss-rails`). The thing being retired is
its hand-written class layer: 576 lines in `app/assets/tailwind/` (`.form-input`, `.section-title`,
and so on) plus the per-screen utility strings. So the migration map is a short one, and the
dead-class check applies once those classes are removed.

### Order of work

Shell first, then shared components, then screens in the order people meet them: Topics, the topic
form, Beacons, then the admin screens. The public home page and sign-in page come last, and only if
they're in scope (open question).

## 2026-11-24: App shell: grouped rail (option A), SkillRx logo blue, full scope

Asked: "for #1 do option A your recommendation, and for scope, include public home page and the
sign-in page as well." Chosen from `previews/shell.html`, which showed three shells on the real
Topics screen, with "Today" alongside.

### The options

- **A: grouped rail.** Topics and Beacons at the top level with icons; Administration a collapsible
  group of seven indented items; account and sign-out pinned at the bottom. Needs a small Stimulus
  controller. Polaris, GitHub repository settings, Linear; and Human Essentials.
- **B: flat rail.** No icons, a static "Administration" heading, every link always visible. No
  JavaScript. Stripe settings, Vercel.
- **C: top bar.** Administration as a menu. Full width for tables, but admin pages are a click
  further and the bar can't show which admin page you're on. GitHub, Basecamp.

Brand: the SkillRx logo blue (`#055889`, 7.6:1 on white) over the system's default indigo, so nav,
links, focus rings and primary buttons match the logo.

### Why this one

Same shell as Human Essentials, so volunteers on both apps meet one layout. Keeps the admin pages
visible to administrators without a wall of links. Follows design.md's sidebar rules: icons on one
level only, sentence-case group header because it's a button, account at the bottom.

### Scope

The public home page (`/`) and the sign-in page (`/session/new`, and the password reset pages that
share its layout) are in scope. They get their own preview before they're built: they are marketing
and entry pages, with different needs from the signed-in app.

### Decided while building it (not separate choices)

- **Beacons stays administrator-only in the nav**, as it was. This migration doesn't re-plan who
  sees what. But note: a contributor who types `/beacons` gets the page (measured 2026-11-24). The
  nav hides it; the controller doesn't. That's an authorization question for SkillRx's maintainers,
  not a design one, so it's recorded here and not changed.
- **Jobs opens in a new tab, as it did**, and now says so: an icon, and "(opens in a new tab)" for
  screen readers (WCAG 3.2.5 advisory, and design.md's link rules).
  *Superseded 2026-11-26: Jobs renders in the shell and opens in place (see below).*
- **The mobile drawer is new.** Below the `md` breakpoint the old sidebar was moved off screen with
  no way to open it, so on a phone there was no navigation at all. Below `lg` there is now a top bar
  with a menu button that opens the rail as a drawer (Escape or the backdrop closes it, focus goes in
  and comes back).
- **A skip link is added**, because there is now a repeated block (the rail) ahead of the content.
- **Administration starts open.** It was first built collapsed except on admin pages (Human
  Essentials' rule). Ten system specs failed, each clicking "Tags" or "Users" from Topics, and that
  was the real cost: one more click for every admin task, to hide seven links that fit anyway. The
  preview chosen showed it open, so it opens by default and can be collapsed.
- **The account strip shows who is signed in**, so specs asserting a user's email is *not on the
  page* now look only inside `<main>`.

### What this does not fix

Every screen's own content still has its old styling (gradient banners, per-screen colors, old
buttons). Those are migrated screen by screen next.

## 2026-11-24: Sign-in is a centered card; home page keeps its sections, without unverified figures

Asked: "Sign in: do B the centered card. make note in this follows patterns for GitHub, Stripe,
Linear, Atlassian. Home page: A, but remove the numbers section. make note of it, so it can be added
back later if numbers are verified. contact email, make both: contact@skillrx.org." Chosen from
`previews/entry.html`.

### Sign-in and password reset: centered card (option B)

Logo, one card holding the form, a link back to the home page. Nothing else on the page.

- **Industry pattern:** GitHub, Stripe, Linear and Atlassian all sign in this way: a single centered
  form, no marketing panel. Only people who already have an account sign in, so the page doesn't
  need to explain what SkillRx is.
- **Rejected: A, split layout** (today's structure, and Human Essentials'). More to keep true and
  up to date, for context these visitors don't need.
- **Applies to all four pages on the session layout:** sign in, forgot password, reset password, and
  the password info panel (which goes; it held a decorative "Security tip").

### Home page: same sections, restyled (option A), minus the numbers

Same content in the same order, with the new look: solid blue hero instead of the animated
gradient, one accent color instead of six, sentence case.

- **The numbers section is removed:** "500+ medical topics, 50+ countries, 10k+ healthcare
  professionals, 24/7 offline access". Nobody could confirm them. **To restore it**, verify each
  figure, then bring back the section from `main`'s `app/views/home/index.html.erb` (the block
  between the features cards and "Our Mission"), restyled like the features cards.
- **The module counts are removed too** (asked separately, same reason): Cardiology 150 modules,
  Emergency 120, Pharmacy 80, Infectious 95. The four subject cards stay, without counts. Same
  restore rule: verify, then add them back.
- **The sign-in panel's "500+ topics" goes with sign-in option B.**

### Contact email

Every "contact us" link uses `contact@skillrx.org`. The sign-in page's linked to a volunteer's own
address, which shouldn't be on a public page.

### "Remember me" is removed

The checkbox wasn't connected to anything: `authentication.rb` sets a permanent session cookie on
every sign-in, checked or not (measured 2026-11-24, line 49). A control that does nothing misleads.
Sign-in behavior doesn't change: you stay signed in until you sign out. If SkillRx wants a real
choice, the unchecked case needs a session cookie, which is a change to authentication, not design.

### Sentence case everywhere

Headings, buttons, labels, nav and table headers use sentence case ("Add new topic", not "Add New
Topic"). Proper names keep their capitals (SkillRx, Ruby For Good). Applied to each screen as it's
migrated, so a screen is never half converted.

### "Join thousands of healthcare professionals" is kept

Asked separately on 2026-11-24, since it's also an unverified figure: kept as is, by decision.

### The home page's illustration is not real data

The hero card (a topic, "Hand hygiene in the clinic", with two documents "Available offline")
illustrates what SkillRx holds. It replaced today's "Cardiology updates, 75% complete", which showed
learner progress, a feature SkillRx's admin app doesn't have. It's hidden from screen readers
(`aria-hidden`), since it isn't content.

## 2026-11-25: Row actions: the title links, Edit is the button; a ⋯ menu at three or more

Asked: "to keep it consistent, go with A, but convert the whole table to B, the menu option if there
are more than 3 actions." Chosen from `previews/topics.html`. Confirmed separately: the menu starts
at **three or more**, the design system's own threshold, not four.

### The rule, for every SkillRx table

- **Two settled actions stay visible.** The record's name in the first column is the link to view
  it, and the other action (Edit) is a button at the end of the row, named for its row ("Edit Hand
  hygiene in the clinic") for screen readers. GitHub, Shopify Polaris and Linear do this.
- **If any row in a table can reach three actions, every row in that table gets a ⋯ menu.** Never
  menus on some rows and buttons on others.
- **If which actions appear depends on state or role, use the menu whatever the count.** For example
  Archive/Unarchive switches with state, and Delete is administrators only.

### Topics

Two actions: the title (view) and Edit, the same on every row. **Archive and Unarchive** (everyone)
and **Delete** (administrators) stay on the topic's own page, as they were. If they ever move into
the list, the rule above makes it a menu.

### Rejected

- **B, a ⋯ menu on every row now:** two clicks for every action, and nothing visible, to hold two
  actions that never vary. The design system calls a menu holding two settled actions a mistake.
- **C, icon buttons:** need learning and a tooltip each.

## 2026-11-25: The topics list's State filter defaults to Active, and stays that way

Asked: "Active by default", choosing between two options.

### What was actually wrong

Three bugs on `main`, found building the filter bar, all measured:
- **Every filter showed its blank option, even on a filtered list.** `_search.html.erb` read
  `params.dig(:search, …)`, but it's rendered with `params: search_params`, already unwrapped, so
  every lookup was nil. The search box lost its text on reload too.
- **Year, month and state compared the URL's text with numbers and symbols** (`"2026"` with `2026`,
  `"archived"` with `:archived`), so even the right lookup would never have matched.
- **With no filters the list showed active topics only** (`search_params` defaults to
  `state: :active`), while the State filter said "Select state". **Using any other filter brought
  archived topics back**, because the filter's blank option meant "any state".

### What it does now

State's options are **Active** (first, the default), **Archived**, and **Any state**. It shows what
the list is doing, and it stays Active as other filters change: archived topics appear only when
someone chooses them. Filters keep their values after a reload, and a filtered list opens its
Filters panel.

Rejected: keeping today's behavior honestly (State showing "Active" before filtering and "Any
state" after). It would have kept a list that changes what it includes without being asked.

### Specs changed

`search_spec.rb`'s language test expected archived topics after choosing a language; it now expects
them only after "Any state". The month tests choose "Any state" first, so they still cover archived
topics.

## 2026-11-25: Beacons: status from what beacons report; real values in the list

Asked, choosing between options: "Counts by sync status" and "Yes, real values".

### What was actually wrong

- **The summary's "Online now" was always 0, and "Offline" was everything.** It counted
  `b[:online]`, an attribute beacons don't have. SkillRx has no definition of "online".
- **Five list columns showed placeholder words**, "current manifest", "latest manifest",
  "is up date?", "last seen at" and "last sync at", in every row.
- **On a beacon's page, "Files included" and "Topics included" were swapped.**
- **The provisioning and regenerate messages repeated the full API key** in the flash, beside the
  panel that shows it.

### What it does now

- **One status per beacon:** Revoked if its key is revoked, otherwise the sync status it reported:
  Synced, Syncing, Needs update, Error, or Never synced (`BeaconsHelper`).
- **The summary counts beacons by that status.** No "online" threshold is invented. Rejected: online
  meaning "seen in the last 24 hours" or "last hour", which would need the field team to confirm.
- **The list shows real values:** status, content version reported against the latest, last seen and
  last synced ("3 days ago", exact time on hover). Region and language sit under the name, so the
  table fits at 1280px.
- **The new key panel** shows the full key once, with Copy; the flash just says to copy it.

## 2026-11-25: Providers, regions and languages: name links, Edit and Delete inline

Following the row-action rule: each list's name links to the record (no View button), which leaves
two settled actions, **Edit** and **Delete**, so they stay visible. Languages has no delete route, so
just Edit. Deleting confirms in the app's dialog.

### Found while migrating

- **The regions list said "1 provider" on every row**, a hardcoded placeholder. It shows the real
  count, which the controller already loaded.
- **Deleting a provider leaves its topics orphaned:** they keep a `provider_id` that no longer exists
  and vanish from every list (measured: 13 of 13 topics on the seeded clinic). No foreign key or
  `dependent:` option prevents it. Not changed here, because what should happen (block, reassign,
  delete) is the app's decision; the confirmation now says how many topics are affected.

## 2026-11-25: Users

Following the same rules: email links to the user, Edit inline; role as a pill (Administrator in the
brand tone, Contributor neutral); search plus two filters, shown inline.

### Found while migrating

- **Deleting a user had no confirmation at all.** The button used `data-confirm`, which Turbo
  ignores, so one click deleted the user. It now confirms in the app's dialog, and you can't delete
  yourself from your own page.
- **The Providers field accepted typed new values** (`allow-new: true`), which were submitted as
  provider ids and failed. Existing providers only now.
- **The seeds linked me@mail.com to the same provider twice**, so it was listed twice. Fixed in
  `db/seeds.rb`.

## 2026-11-25: Plain, utilitarian subtitles and helper text

Asked: "do a sweep of all subtitles and helper text, make them more utilitarian and plain language,
for example -- Educational topics and the documents in them -- is not helpful to the user."

Swept every page subtitle, field hint, form lede and empty state (inventoried with grep, not by
memory). List pages lose their descriptive subtitles; Topics' subtitle now names the provider being
shown. Hints keep only formats, limits and consequences. The rule is in design.md, "Subtitles and
helper text".

### Two false claims, found by checking each line against the code

- **The user form said passwords need at least 8 characters.** There's no such validation
  (`has_secure_password` only caps them at 72). It now says "Up to 72 characters."
- **The beacon form said to leave providers and topics blank to include everything**, and the beacon
  page showed "All providers" and "All topics in its language and region" when none were chosen. In
  fact a beacon's manifest holds only the providers and topics chosen on it
  (`Beacons::ManifestBuilder#build_providers`, `#topics`), so blank means no content. The form and
  page now say so. The old app made the same claim; it predates this migration.

## 2026-11-25: Buttons conform to the design system's rules

Asked: "why are the delete buttons red, what is the rule for destructive buttons? do a button audit
make sure they conform."

### Why they were red, and the rule

They were `button-ghost` plus a `text-danger` class: red at rest. The design system's rule is the
opposite: **a destructive action with no fill is neutral at rest and red only on hover and focus**
(`ghost_danger`), because repeated red says nothing the word doesn't, and the confirmation is what
protects people. It also names this exact construction (ghost plus a red text color) as the thing
not to do. **Filled red is only for the button that carries out the destruction, in the
confirmation.**

### Measured

`button-audit.js` (page headers), before: **7 findings on 4 record pages.** Edit was a primary placed
first on the topic, provider, region and tag pages (a right-aligned header puts the primary last),
and on three of them Delete took the last slot, the `/product_drives` mistake design.md describes.
After: 0.

`button-rules-audit.js` (new; every button on every screen as both roles, 149 buttons on 42 visits):
**17 findings against the old buttons, 0 after.** It checks variants, red-at-rest, filled danger
outside confirmations, row actions, one primary, form action order, heights and links that change
data.

### What changed

- `.button-ghost-danger`: neutral at rest, rose on hover and focus. Used for every Delete, Remove and
  Revoke outside a confirmation, including Remove on a topic's documents.
- Record pages have no primary: Delete first, Edit last as secondary. Rejected: keeping Edit as the
  primary, which design.md's "not every page needs a primary" argues against for pages whose job is
  to be read.

### Upstream

`button-audit.js` read variants from Human Essentials' Tailwind class strings, so on SkillRx every
button read "unknown". It now takes an optional `BUTTON_VARIANTS` adapter export, and checks the
destructive-action-in-the-last-slot case it didn't.

## 2026-11-25: rail without icons, one spacing rhythm

**Asked:** remove the icons from the side nav; the spacing between Topics, Beacons and
Administration didn't look right.

### Why it looked wrong
The rail used global design.md's Local numbers: 16px between top-level entries, 2px inside a
group. In Human Essentials the top level is mostly collapsed groups, so 16px separates sections.
Here, Topics and Beacons are plain links, so 16px pulled two sibling rows apart while the seven
Administration rows sat 2px apart: two spacing systems in one short list.

### Industry practice
GitHub, Linear, Stripe and Vercel keep rail rows 32 to 40px tall and 0 to 4px apart, and mark a
new section with a larger gap or a heading, not by spacing every top-level row apart.

### Changed
- Icons removed from Topics, Beacons and Administration. Kept: the group chevron (it says the row
  opens), the external-link mark on Jobs (it says it leaves the app), the account menu's dots.
- 2px between every row; 12px above the Administration group; 2px from its header to its first item.
- Administration's items indent 24px (was 40px, which lined up with text after an icon).

### Measured
Rows at 1280px: Topics 80, Beacons 121 (2px gap), Administration 173 (12px gap), Providers 214
(2px gap), then 2px apart to Jobs.

### Upstream
Not changed yet. Global design.md's spacing table (16px between top-level entries) is labeled
Local; whether it should say "16px between sections, 2px between rows" is a design-system decision.

## 2026-11-26: Topics' provider becomes a filter, with All providers

**Asked:** search, filters and "Switch provider" didn't flow; why wasn't "Switch provider" a label
above its field; isn't provider a filter; why no "All"; would All need a column? Then: "Provided by
the government feels so wordy", fine-tune the copy and build D.

### What was wrong
"Switch provider" was a real `<label>`, but beside its field at desktop width and above it on phones,
on a third row below the filters it decides. It named an action, not a value. The dropdown left out
the current provider (it was the prompt text), and the subtitle repeated it.

### Options (preview `previews/topics-provider.html`)
- **A: scope switcher in the page header** (GitHub branch picker, Google Analytics property). My
  first recommendation, on the grounds that provider is a scope, not a filter.
- **B: first field in the toolbar.**
- **C: switcher at the top of the rail** (Linear, Vercel). Rejected: only Topics uses it.
- **D: provider filter with All providers and a Provider column.** Chosen.

### Why D
For administrators the provider was only ever a filter. Its one other job was choosing the provider
of a contributor's new topic, which a form field does better. One-at-a-time was how it was first
built (`ee3452c`), not a requirement. With All, someone with several providers sees everything they
can edit, and narrows it like any other filter.

### Copy
- Field label **Provider** (was "Switch provider": an action, not the value).
- Options **All providers**, then each provider by name.
- Subtitle "From …" removed: the field says it.
- The table caption, read by screen readers, says "Topics from all providers" or "Topics from <name>".
- Seed provider **Ministry of Health** (was "Provided by the government": a sentence, not a name,
  and it repeated "provider" next to the label). It's seed data only; real providers name
  themselves, and the app never rewrites their names.

### Found while building
- Turbo prefetches a link on hover, and the request for Clear filters saved "All". Hovering reset
  the remembered provider. Fixed in two places (the server ignores prefetches, the link doesn't
  prefetch).
- Turbo's cached preview of `/topics` showed the old filters, and sometimes stayed. The list now
  opts out of previews.

### Measured
517 examples, 0 failures (search specs 5 runs in a row clean); WCAG 0; button audits 0 and 0; no
sideways scroll at 390px; Provider and Search bottoms aligned at 1280px (both 151px). No Bullet
warnings on the list.

## 2026-11-26: Sort moves out of the filters; the row stays put

**Asked:** "when the filter button is triggered, it drops all the filters to the line below and
search stays above in the middle of the line, it looks pretty wonky." Then: "move sort out and log
the reason for the decision."

### Why it looked wonky
Provider sat outside `<rfg-filter-bar>` (its always-visible slot held one field), aligned to the
bar's bottom edge. Opening Filters made the bar taller, so Provider dropped to the panel's last line
and the panel started under Search.

### Fixed upstream (design system 0.1.7)
The `search` slot now takes several fields, so Provider and Search share the first row and the panel
opens below the whole row from its left edge. Measured at 1280px: Provider, Search and Sort tops are
110px before and after opening; at 390px, no sideways scroll.

### Why sort moved out
- **Sort isn't a filter.** A filter changes which topics are listed; sort only changes their order.
  Folded among the filters, it counted toward the panel's six fields, and at 1280px the sixth wrapped
  onto a line by itself.
- **Clear filters reset it.** Someone who chose "Oldest first" and clears a language filter still
  wants oldest first. Now Clear filters keeps the sort and resets everything else.
- **It's where people look for it:** at the far end of the row, as on GitHub, Gmail and Shopify Polaris.
- Applied to every list with a sort (Topics, Tags, Users), so it's one rule. Tags drops Clear filters:
  with Sort out, the only thing left to clear is Search, which has its own ×, and the design system
  says a bar shouldn't offer two ways to undo one thing.

### Also changed
- **Clear filters is a submit button.** As a link it was drawn with the page, so after changing Sort
  it carried the old order. As a button it sends the current sort; the server redirects with the sort
  kept and the rest dropped.
- **Sort options say the order:** "Newest first" and "Oldest first" everywhere; on Tags "Name (A–Z)",
  "Most used" and "Least used".
- **Two specs waited on the wrong page.** Tags and Users specs chose a sort right after clicking the
  nav link; Topics (where sign-in lands) now has a visible Sort with the same id, so they picked that
  one. They now wait for the page's heading first.

### Measured
518 examples, 0 failures (the three list specs twice more, clean); WCAG 0; button audits 0 and 0.

## 2026-11-26: even spacing in the rail and the filter row

**Asked:** "there is not enough padding between the provider and search inputs, also there is
uneven padding between beacons and admin."

- **Rail:** Topics to Beacons was 2px, Beacons to Administration 14px (the 12px I'd added on
  2026-11-25 so the group read as a section). With three top-level rows that reads as uneven, not as
  a section break, and the chevron and indented items already say "group". Now 2px throughout.
- **Filter row:** Provider to Search was 12px; the panel's columns are 16px. Now 16px, so every field
  in the bar is the same distance from the next. Fixed in the design system (`44128cb`, with a check
  that fails at 12px), not yet released; until it is, `sm:mr-1` on the Provider field adds the 4px
  in SkillRx. Remove it on upgrade.

## 2026-11-26: Jobs in the design system

**Asked:** "migrate the job page to the design system. It looks completely different at the moment."

**Before:** Mission Control Jobs' own layout: Bulma, a "Back to main app" link, no rail, opened in
a new tab. Listed under "Not migrated" because restyling a gem's views means maintaining a fork.

**Decision:** render it inside the app shell and override as little as possible.
- **Override the layout, not the pages.** Rails lets an app override an engine's views by path. The
  layout plus three small partials beside it, and the six partials that hold buttons, are
  overridden; the page templates render as shipped. That's 10 short files to diff on an upgrade,
  not ~50. This is how Sidekiq Web, GoodJob and Mission Control are usually brought into an admin
  area: the host's chrome around them, the engine's content inside.
- **Style Bulma's class names, don't load Bulma.** `components/jobs.css` maps the ~30 names the
  templates use onto the app's tokens, scoped to `.jobs-engine`.
- **Buttons are overridden, not mapped,** so they carry the app's real variants and the button
  audits check them like any other: row actions ghost at 32px, Discard ghost-danger, confirmations
  in the app's dialog.
- **Jobs opens in place**, with no external-link mark: it's no longer a different app.

**Found on the way:**
- `<rfg-page-tabs>` lost its whole look under Tailwind's preflight: a page's rules beat `::slotted`.
  Fixed in the design system (`!important` on slotted declarations, with a story under a reset and
  a check that fails on the old component). Until SkillRx is on that release, `jobs.css` sets the
  same values from the light DOM.
- The WCAG audit sorted screens into roles by an `admin/` controller prefix, which SkillRx doesn't
  use, so every admin screen was visited as a contributor, redirected to Topics, and audited as
  Topics. It now uses the adapter's `ADMIN` rule: 46 pages audited (was 36), 0 violations.
- Inside the engine, every URL gets `?server_id=`, the app's own links too. The shell uses
  `shell_path(:name)`, which drops it.

**Measured:** 528 examples, 0 failures; WCAG 0 on 46 pages; button audits 0 and 0 (175 buttons on
52 screen visits). No sideways page scroll at 390px.

