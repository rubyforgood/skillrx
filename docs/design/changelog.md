# Design change log

One row per commit: the commit, and what changed, in a sentence that will still mean something in a
year. Write PENDING, commit, then fill in the hash in the next commit.

| Commit | Change |
| --- | --- |
| `PENDING` | Set up the migration: `docs/design/` (spec, decision log, this log), the audit adapter (`bin/design/targets.js`, `route-targets.rb`: 28 screens, two roles, measured), `wcag-audit.js` running end to end, and the first preview (`docs/design/previews/shell.html`). No app code changed. |

### Baseline WCAG audit, before any change

`node bin/design/wcag-audit.js` on 2026-11-24 (axe-core 4.13.0, WCAG 2.1 A/AA, 33 pages: 28 screens
signed in, plus 5 signed out). Exit 1: **4 distinct violations, 83 elements.**

| Rule | Elements | Pages | Example |
| --- | --- | --- | --- |
| `color-contrast` (serious) | 42 | 28 | Indigo text on white in the home page hero |
| `html-has-lang` (serious) | 25 | 25 | `<html>` in `layouts/application.html.erb` has no `lang` |
| `link-name` (serious) | 10 | 6 | Footer's icon-only LinkedIn/GitHub/email links |
| `select-name` (critical) | 6 | 2 | The topic form's published year and month selects have no label |
