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
