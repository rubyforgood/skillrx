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
