# Onboarding: maintaining SkillRx's design

For anyone changing what SkillRx looks like or how its screens behave. If you're using SkillRx to
manage topics and beacons, read [the guide for people using SkillRx](guide-for-users.md) instead.

## The short version

- SkillRx uses the **[Ruby For Good design system](https://github.com/rubyforgood/designsystem)**.
  Its [`design.md`](https://github.com/rubyforgood/designsystem/blob/main/design.md) is the rulebook.
- **[`design.md`](design.md) in this folder** holds only what's specific to SkillRx: the brand
  color, the navigation, each screen. If neither document answers your question, write the answer
  down here before changing the code.
- **[`decisions.md`](decisions.md)** says why things are the way they are, and what was rejected.
  Read it before changing something that looks odd: it's probably deliberate.
- **[`changelog.md`](changelog.md)** lists every design change, one row per commit.
- **US English spelling and sentence case**, always: "Add new topic", not "Add New Topic". Proper
  names keep their capitals (SkillRx, Ruby For Good).

## Where things live

| What | Where |
| --- | --- |
| Design tokens (color, type, spacing, radius, shadow) | `app/assets/tailwind/rfg-theme.css` (vendored, don't edit) |
| SkillRx's own values (brand blue) and shared classes | `app/assets/tailwind/application.css` |
| App shell: sidebar, account menu, mobile drawer | `app/views/layouts/application.html.erb`, `_sidebar.html.erb`, `app/javascript/controllers/shell_controller.js`, `app/assets/tailwind/components/sidebar.css` |
| Sign-in and password pages | `app/views/layouts/session.html.erb`, `sessions/`, `passwords/` |
| Public home page | `app/views/layouts/home.html.erb`, `home/index.html.erb` |
| Design system components | `vendor/javascript/rfg-*.js`, pinned in `config/importmap.rb` |
| The Figtree font | `app/assets/fonts/figtree/` |
| Audit adapter and audits | `bin/design/` |
| Previews of design options | `docs/design/previews/` |

## Building a screen

1. **Check the rulebook first.** Most questions (what a table looks like, where a page's main
   button goes, how errors show) are already answered in the global `design.md`.
2. **Use the shared pieces, not new utility classes.**
   - Components: `<rfg-button>`, `<rfg-field>`, `<rfg-callout>`, `<rfg-menu>`, `<rfg-avatar>`
     are vendored. The other 24 are in the design system's
     [Storybook](https://rubyforgood.github.io/designsystem/); vendor one when you need it (below).
   - Form controls: `.form-input`, `.form-select`, `.form-textarea`, `.form-label`, wrapped in
     `<rfg-field label="…">`.
   - Colors: `brand-*` for actions and the current page, `neutral-*` for everything else, and the
     semantic tones (success, warning, danger, info) only for meaning. No other hues.
3. **If two good answers exist, it's a design decision.** Make a preview (see below), get it chosen,
   and record it in `decisions.md`. If the rulebook already answers it, just follow it.
4. **Apply it everywhere it fits,** not just on the page you're on.
5. **Record it** in `design.md` and `changelog.md`, in the same pull request as the code.

## Previews

A preview is a standalone HTML page in `docs/design/previews/` showing 2 to 4 real options, today's
version alongside, what each costs, who else does it, and a recommendation. To view one while the
app runs:

```bash
mkdir -p public/design-previews && cp docs/design/previews/* public/design-previews/
# then open http://localhost:3000/design-previews/<name>.html
```

`public/design-previews/` is gitignored; the tracked copy is in `docs/design/previews/`.

## Adding or upgrading a design system component

Components are vendored as standalone files (Lit bundled in), at a pinned version:

```bash
V=https://cdn.jsdelivr.net/npm/@rubyforgood/design-system@0.1.10
curl -fo /tmp/x.mjs $V/dist/standalone/modal.mjs
# add the four-line provenance header (copy it from any vendor/javascript/rfg-*.js), then:
#   vendor/javascript/rfg-modal.js
#   config/importmap.rb:          pin "rfg-modal", to: "rfg-modal.js"
#   app/javascript/application.js: import "rfg-modal"
```

**Upgrading** means changing the version in `V` and downloading every `rfg-*.js` and
`rfg-theme.css` again. Read the release notes first.

**Never edit a vendored file.** SkillRx-specific values go in `application.css`.

## Running the checks

**Specs:** `bundle exec rspec`, the whole suite, before every commit that changes a screen. A shared
helper can depend on any screen's markup: sign-in once broke 47 specs elsewhere. The system specs need Chrome; if Selenium fails with
`* is not a valid URL` (Chrome 158 and later), run them against Chrome 157:
`SE_BROWSER_VERSION=157 bundle exec rspec`.

**Accessibility audit** (axe-core on every screen, as an administrator and as a contributor, plus the
signed-out pages). With the app running on port 3200 and the database seeded:

```bash
npm install --no-save --prefix /tmp/rfg-audit playwright@1.55.0
npx --prefix /tmp/rfg-audit playwright install chromium
npm install --no-save --prefix /tmp/axe axe-core
NODE_PATH=/tmp/rfg-audit/node_modules node bin/design/wcag-audit.js
NODE_PATH=/tmp/rfg-audit/node_modules node bin/design/button-audit.js        # page headers
NODE_PATH=/tmp/rfg-audit/node_modules node bin/design/button-rules-audit.js  # every other button
```

It visits every screen in `bin/design/route-targets.rb`, which reads the routes, so a new screen is
included automatically. Never replace that with a hand-written list of pages. Sign-in is
rate-limited (10 attempts in 3 minutes), so running several audits back to back can lock you out
for a few minutes.

## Things that will catch you out

- **`<rfg-button>` moves its `aria-label` onto its inner button.** In a spec, find it by role
  (`click_button("Account menu")` won't work through the shadow root; use
  `find(".shell-account rfg-button").click`).
- **`<rfg-button href>` only becomes a link once JavaScript runs.** On pages that must work without
  it (the home page), use a plain `link_to` with a button class.
- **The rail shows the signed-in user's email.** A spec asserting an email is *not* on the page must
  look inside `<main>`.
- **Herb (the dev template validator) rejects ERB as a bare attribute**
  (`<ul <%= "hidden" if x %>>`). Use `tag.ul hidden: x` instead.
- **Tailwind only emits theme variables it sees used,** and the components read them from inside
  shadow roots where Tailwind can't see. That's why the theme is imported with `theme(static)`.

- **Filters fold behind a button in two shadow roots.** In system specs use `select_filter "X",
  from: "search_y"` and `open_filters` (`spec/support/system_helpers.rb`); they wait for Turbo to
  settle, then open the panel with a script, since Selenium loses track of nested shadow roots.
- **Wait for TomSelect's option before pressing Enter** (`enter_and_choose_tag` does). Pressed
  early, Enter submits the form and nothing is chosen.

## Open items

- **Home page, to confirm with the SkillRx team** (decisions.md, 2026-11-27, "The mission section
  leads with the mission"):
  - The subject list (Cardiology, Emergency medicine, Pharmacy, Infectious diseases) is typed into
    `home/index.html.erb`. Check it against the real catalog, or replace it with real ones.
  - "No fees, no subscriptions, no account needed to learn from a beacon." Confirm health workers
    don't need an account to read a beacon's content.
  - "Join thousands of healthcare professionals…" was removed on 2026-11-27, reversing the
    2026-11-24 decision to keep it. Restore it only with a real figure.

- **Deleting a provider orphans its topics** (no foreign key or `dependent:`). The delete
  confirmation says how many; the app should decide whether to block it, reassign or delete them.

- Beacons are hidden from contributors in the nav, but `/beacons` doesn't stop them (see
  `decisions.md`). An authorization question for the app's maintainers.
- `registrations#new` and `topics/tags#index` are routed but have no controller; both 500.
- The remaining signed-in screens are migrated one at a time; `design.md`'s Status section says
  which.
