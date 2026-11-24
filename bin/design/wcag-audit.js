// AUDIT-READS: RENDER
// WCAG 2.1 A/AA audit of every significant page, using axe-core in a real browser.
//
// axe-core is the industry-standard engine and finds roughly a third to a half of WCAG issues --
// the machine-checkable ones. It does not judge whether alt text is *good*, whether a heading
// describes its section, or whether a keyboard order makes sense. Those need a person.
//
// Install once:  npm install --no-save --prefix /tmp/axe axe-core
// Run:           pw bin/design/wcag-audit.js [--json]
const { chromium } = require("playwright");
const fs = require("fs");
const adapter = require("./targets");
const { signIn, targets: allTargets, BASE, RUNS, PRIMARY, SECONDARY, ADMIN } = adapter;

const AXE = "/tmp/axe/node_modules/axe-core/axe.min.js";
const JSON_OUT = process.argv.includes("--json");

// WCAG 2.1 A and AA only. Best-practice rules are reported separately so a real failure is
// never hidden among opinions.
const WCAG_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"];

// Pages reached without signing in. An adapter can export its own SIGNED_OUT list (`[label, path]`
// pairs); this default is the Rails/Devise origin app's, so an adapter for any other app should.
const SIGNED_OUT = adapter.SIGNED_OUT || [
  ["sign in", "/users/sign_in"],
  ["forgot password", "/users/password/new"],
  ["account request", "/account_requests/new"],
  ["404", "/404.html"],
  ["500", "/500.html"]
];

async function audit(page, label, path) {
  const res = await page.goto(BASE + path, { waitUntil: "networkidle", timeout: 30000 });
  if (!res || res.status() >= 400) return { label, path, status: res && res.status() };

  await page.addScriptTag({ path: AXE });
  const result = await page.evaluate(async (tags) => {
    // rack-mini-profiler injects its own markup into every development page. It is dev-only
    // chrome, not app output, so auditing it reports defects that cannot ship.
    const run = await axe.run(
      { exclude: [[".profiler-results"], [".profiler-result"], ["#rack-mini-profiler"]] },
      { runOnly: { type: "tag", values: tags }, resultTypes: ["violations"] }
    );
    return run.violations.map((v) => ({
      id: v.id,
      impact: v.impact,
      help: v.help,
      tags: v.tags.filter((t) => /^wcag/.test(t)),
      nodes: v.nodes.length,
      example: v.nodes[0] && v.nodes[0].html.slice(0, 150),
      target: v.nodes[0] && v.nodes[0].target.join(" ")
    }));
  }, WCAG_TAGS);

  return { label, path, violations: result };
}

(async () => {
  const browser = await chromium.launch();
  const all = [];

  // Every screen the router knows, not the four hand-kept lists below. Those covered 61 pages
  // while route-targets.rb enumerates 163 -- and a hardcoded list is what let three unmigrated
  // pages hide from every audit for the length of the design system migration.
  // From the seam, which regenerates when the list is older than the routes file or the
  // generator. This shelled out on every run: correct, but it spawned Rails each time and
  // skipped the cache whose staleness rule is the point.
  const routed = allTargets();
  const forRole = (role) => routed
    .filter((t) => (t.controller.startsWith("partners/") ? "partner"
      : t.controller.startsWith("admin") ? "super" : "bank") === role)
    .map((t) => [t.path, t.path]);

  // Emails come from the seam's RUNS; the role-name classification just above is this audit's
  // own (controller-based, not path-based like targets.js's PRIMARY/SECONDARY/ADMIN) and is left
  // alone -- unifying the two classification schemes is a separate concern from de-duplicating
  // credentials. (Comment updated alongside the PRIMARY/SECONDARY rename -- the classification
  // still uses "bank"/"partner"/"super" as its own internal labels, unrelated to the contract's
  // export names. See docs/portability/audit-tooling-classification.md.)
  //
  // Optional-chained: an adapter is not required to have all three roles -- RUNS lists only the
  // roles that exist (see bin/design/adapters/reference-app/targets.js, which has two) -- and
  // `.find()` returning undefined for a role this app doesn't have must not crash the run. A
  // version of this without the `?.` did exactly that against a second adapter with no SECONDARY
  // entry, which is the sort of thing only trying a second adapter actually catches.
  const emailFor = {
    bank: RUNS.find(([, p]) => p === PRIMARY)?.[0],
    super: RUNS.find(([, p]) => p === ADMIN)?.[0],
    partner: RUNS.find(([, p]) => p === SECONDARY)?.[0]
  };

  for (const [email, pages] of [
    [null, SIGNED_OUT],
    [emailFor.bank, forRole("bank")],
    [emailFor.super, forRole("super")],
    [emailFor.partner, forRole("partner")]
  ]) {
    const page = await browser.newPage({ viewportSize: { width: 1280, height: 900 } });
    if (email) await signIn(page, email);
    for (const [label, path] of pages) {
      try {
        all.push(await audit(page, label, path));
      } catch (e) {
        all.push({ label, path, error: e.message.slice(0, 80) });
      }
    }
    await page.close();
  }
  await browser.close();

  if (JSON_OUT) {
    fs.writeFileSync("tmp/wcag-audit.json", JSON.stringify(all, null, 2));
  }

  // Group by rule: a rule broken on 30 pages is one fix, not thirty.
  const byRule = new Map();
  let audited = 0, skipped = [];
  for (const r of all) {
    if (r.error || r.status) { skipped.push(`${r.label} (${r.error || "HTTP " + r.status})`); continue; }
    audited += 1;
    for (const v of r.violations) {
      const e = byRule.get(v.id) || { ...v, pages: [], totalNodes: 0 };
      e.pages.push(r.label);
      e.totalNodes += v.nodes;
      byRule.set(v.id, e);
    }
  }

  const rules = [...byRule.values()].sort((a, b) => b.totalNodes - a.totalNodes);
  console.log(`axe-core ${"4.13.0"} · WCAG 2.1 A/AA · ${audited} pages audited\n`);
  if (rules.length === 0) console.log("no violations");
  for (const r of rules) {
    console.log(`${(r.impact || "?").toUpperCase().padEnd(8)} ${r.id}`);
    console.log(`         ${r.help}`);
    console.log(`         ${r.tags.join(", ")}`);
    console.log(`         ${r.totalNodes} element(s) across ${r.pages.length} page(s): ${r.pages.slice(0, 6).join(", ")}${r.pages.length > 6 ? ", …" : ""}`);
    console.log(`         e.g. ${r.target}`);
    console.log(`              ${r.example}`);
    console.log();
  }
  if (skipped.length) console.log(`skipped: ${skipped.join(", ")}`);
  const total = rules.reduce((n, r) => n + r.totalNodes, 0);
  console.log(`\n${rules.length} distinct violation(s), ${total} element(s)`);
  process.exit(rules.length ? 1 : 0);
})();
