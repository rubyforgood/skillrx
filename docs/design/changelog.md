# Design change log

One row per commit: the commit, and what changed, in a sentence that will still mean something in a
year. Write PENDING, commit, then fill in the hash in the next commit.

| Commit | Change |
| --- | --- |
| `b533583` | Set up the migration: `docs/design/` (spec, decision log, this log), the audit adapter (`bin/design/targets.js`, `route-targets.rb`: 28 screens, two roles, measured), `wcag-audit.js` running end to end, and the first preview (`docs/design/previews/shell.html`). No app code changed. |
| `6373a2d` | App shell (option A): grouped rail, mobile drawer (new: phones had no navigation), skip link, account menu with Sign out, footer no longer fixed. Design system tokens, SkillRx blue, self-hosted Figtree, `<html lang="en">`. Three components vendored (avatar, button, menu). WCAG audit: 4 violations on 83 elements → 3 on 58; none in the shell. Specs: 516, 0 failures (3 specs updated for the account menu and the email now shown in the rail). |
| `ceed409` | Sign-in and password pages: centered card, `<rfg-field>` labels, messages as callouts in the card, no "Remember me" (it did nothing), contact@skillrx.org. Form controls app-wide: neutral-500 border (4.76:1), brand focus outline. Vendored callout and field. axe clean on both pages. |
| `ddb398d` | Home page: same sections restyled (solid brand hero, one accent color, no entrance animation), numbers section and module counts removed, footer links named, mobile menu, plain-link primary actions, contact@skillrx.org. `home_controller.js` replaced by CSS smooth scroll. |
| `c97df6e` | Onboarding docs: `onboarding-maintainers.md` and `guide-for-users.md`. WCAG audit after shell, sign-in and home: 3 violations on 38 elements (from 4 on 83), measured with the setup the maintainer doc gives. |
| `d92044f` | Upgraded to design system 0.1.4; removed the `--radius-pill` workaround (avatar still round, measured). Fixed `spec/support/system_helpers.rb`, which filled sign-in by placeholder text: `ceed409` removed the placeholders and broke 47 system specs, because that checkpoint ran only the login and request specs. Full suite now 516, 0 failures. **Rule from this:** run the full suite at every checkpoint. |
| `29667b9` | Topics list on the design system: page header, filter bar (search visible, filters folded and open when set), table with row-title links and a row-named Edit, status pills, pagy restyled. Upgraded to design system 0.1.5. Fixed three bugs on `main`: filters never showed their values, year/month/state never matched the URL, and filtering by anything brought archived topics back (State now defaults to Active). 516 examples, 0 failures. |
| `428f41b` | Topics area: add/edit form (form_field helper, sections, error summary; fixes the year/month labels pointing at missing ids), topic page (panels, details list, documents with download), in-place delete confirmation, archive. Shared: flash as callouts, the app's confirm dialog for every `turbo_confirm`, TomSelect on tokens, red text at rose-700. Upload controller moved to the form (its Save button target is outside the documents section). 516 examples, 0 failures; 8 browser flows pass; axe clean on all four topic screens. |
| `1b15360` | Beacons: list with real status, content version and last-seen values (were placeholder words), counts by sync status (online count was always 0), beacon page with the counts un-swapped and a one-time key panel, form on form_field, the app's confirm dialog for regenerate/revoke. Seeds: content versions. Specs: `wait_for_turbo` after navigation (two search specs were flaky); beacon view spec asserts meaning, not color classes. 514 examples, 0 failures. |
| `44f5095` | Providers, regions, languages: lists with name links and inline Edit/Delete, record pages, forms on form_field (submit labels "Add provider"/"Save provider" and so on). Regions show the real provider count (was "1 provider" on every row). The provider delete confirmation warns how many topics would be orphaned. 514 examples, 0 failures. |
| `611522c` | Tags: list with search and sort in the filter bar (two controls, so inline), name links, cognate chips, topic counts; tag page with its topics and cognates; in-place delete confirmation saying how many topics lose the tag; form on form_field. |
| `82417d3` | Users: list (avatar, email link, role pill, providers, inline filters), user page (access and record), form on form_field with an Administrator checkbox and existing-providers-only. Delete now confirms (it used `data-confirm`, which Turbo ignores: one click deleted). Seeds: no duplicate provider link. |
| `PENDING` | Import reports (list with status filter, report page with errors and summary), static error pages (400, 404, 406, 422, 500) in SkillRx's look. Retired 69 unused legacy CSS rules, `animations.css` and the dropdown-arrow partial; pagination's current page back on the brand color. **Migration complete:** WCAG audit 0 violations on 36 pages (from 4 kinds on 83 elements); 42 screen visits at 390px clean; 514 examples, 0 failures. |

### Baseline WCAG audit, before any change

`node bin/design/wcag-audit.js` on 2026-11-24 (axe-core 4.13.0, WCAG 2.1 A/AA, 33 pages: 28 screens
signed in, plus 5 signed out). Exit 1: **4 distinct violations, 83 elements.**

| Rule | Elements | Pages | Example |
| --- | --- | --- | --- |
| `color-contrast` (serious) | 42 | 28 | Indigo text on white in the home page hero |
| `html-has-lang` (serious) | 25 | 25 | `<html>` in `layouts/application.html.erb` has no `lang` |
| `link-name` (serious) | 10 | 6 | Footer's icon-only LinkedIn/GitHub/email links |
| `select-name` (critical) | 6 | 2 | The topic form's published year and month selects have no label |
