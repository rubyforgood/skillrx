// SkillRx's adapter for the Ruby For Good design system audits
// (https://github.com/rubyforgood/designsystem, bin/design/README.md). It is the only file that
// knows this is Rails with has_secure_password sign-in at /session/new. Copy an audit from the
// design system's bin/design/ next to this file and it runs unmodified.
//
// Roles: SkillRx has two audiences, administrators and contributors (users.is_admin). Admin-only
// screens are gated by `require_admin`, which redirects a contributor. There is no third audience,
// so SECONDARY is an honest "no such role here".
const path = require("path");
const fs = require("fs");
const { execSync } = require("child_process");

const BASE = process.env.BASE_URL || "http://127.0.0.1:3200";
const PASSWORD = process.env.SEED_PASSWORD || "test123"; // db/seeds.rb
const ROOT = path.resolve(__dirname, "../..");
const TARGETS_FILE = process.env.TARGETS || path.join(ROOT, "tmp/design-targets.json");
const GENERATE = process.env.TARGETS_CMD || "bin/rails runner bin/design/route-targets.rb";

// Regenerate when missing or older than the routes file, so a new screen is never skipped.
function stale() {
  if (!fs.existsSync(TARGETS_FILE)) return true;
  return fs.statSync(TARGETS_FILE).mtimeMs < fs.statSync(path.join(ROOT, "config/routes.rb")).mtimeMs;
}

let cached = null;
function targets() {
  if (cached) return cached;
  if (stale()) fs.writeFileSync(TARGETS_FILE, execSync(GENERATE, { cwd: ROOT, maxBuffer: 8 * 1024 * 1024 }));
  cached = JSON.parse(fs.readFileSync(TARGETS_FILE, "utf8"));
  return cached;
}

// Screens only an administrator reaches. Measured 2026-11-24 by visiting every target as each role:
// these six controllers redirect a contributor to /topics. Beacons are visible to both roles.
const ADMIN_CONTROLLERS = new Set(["users", "regions", "providers", "languages", "tags", "import_reports"]);
const byPath = (p) => targets().find((t) => t.path === p);
const ADMIN = (p) => { const t = byPath(p); return !!t && ADMIN_CONTROLLERS.has(t.controller); };
const SECONDARY = () => false;
const PRIMARY = (p) => !ADMIN(p);

const RUNS = [
  [process.env.PRIMARY_EMAIL || "me@mail.com", PRIMARY],
  [process.env.ADMIN_EMAIL || "admin@mail.com", ADMIN],
];

async function signIn(page, email, password = PASSWORD) {
  await page.context().clearCookies();
  await page.goto(BASE + "/session/new", { waitUntil: "domcontentloaded" });
  await page.fill('input[name="email"]', email);
  await page.fill('input[name="password"]', password);
  await page.click('form[action="/session"] [type="submit"]');
  await page.waitForURL((u) => !u.pathname.startsWith("/session"), { timeout: 30000 });
}

async function visit(page, urlPath, { timeout = 30000 } = {}) {
  const res = await page.goto(BASE + urlPath, { waitUntil: "domcontentloaded", timeout }).catch(() => null);
  if (!res || res.status() >= 400) return null;
  await page.waitForLoadState("load", { timeout: 3000 }).catch(() => {});
  res.landed = new URL(page.url()).pathname;
  return res;
}

// Pages a signed-out visitor reaches. Not from the route list: these render only when signed out.
const SIGNED_OUT = [
  ["home", "/"],
  ["sign in", "/session/new"],
  ["forgot password", "/passwords/new"],
  ["404", "/404.html"],
  ["500", "/500.html"],
];

module.exports = { BASE, PASSWORD, targets, signIn, visit, RUNS, SECONDARY, ADMIN, PRIMARY, SIGNED_OUT };
