# Design change log

One row per commit: the commit, and what changed, in a sentence that will still mean something in a
year. Write PENDING, commit, then fill in the hash in the next commit.

| Commit | Change |
| --- | --- |
| `b533583` | Set up the migration: `docs/design/` (spec, decision log, this log), the audit adapter (`bin/design/targets.js`, `route-targets.rb`: 28 screens, two roles, measured), `wcag-audit.js` running end to end, and the first preview (`docs/design/previews/shell.html`). No app code changed. |
| `6373a2d` | App shell (option A): grouped rail, mobile drawer (new: phones had no navigation), skip link, account menu with Sign out, footer no longer fixed. Design system tokens, SkillRx blue, self-hosted Figtree, `<html lang="en">`. Three components vendored (avatar, button, menu). WCAG audit: 4 violations on 83 elements → 3 on 58; none in the shell. Specs: 516, 0 failures (3 specs updated for the account menu and the email now shown in the rail). |
| `PENDING` | Sign-in and password pages: centered card, `<rfg-field>` labels, messages as callouts in the card, no "Remember me" (it did nothing), contact@skillrx.org. Form controls app-wide: neutral-500 border (4.76:1), brand focus outline. Vendored callout and field. axe clean on both pages. |

### Baseline WCAG audit, before any change

`node bin/design/wcag-audit.js` on 2026-11-24 (axe-core 4.13.0, WCAG 2.1 A/AA, 33 pages: 28 screens
signed in, plus 5 signed out). Exit 1: **4 distinct violations, 83 elements.**

| Rule | Elements | Pages | Example |
| --- | --- | --- | --- |
| `color-contrast` (serious) | 42 | 28 | Indigo text on white in the home page hero |
| `html-has-lang` (serious) | 25 | 25 | `<html>` in `layouts/application.html.erb` has no `lang` |
| `link-name` (serious) | 10 | 6 | Footer's icon-only LinkedIn/GitHub/email links |
| `select-name` (critical) | 6 | 2 | The topic form's published year and month selects have no label |
