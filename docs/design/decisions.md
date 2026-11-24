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
