// AUDIT-READS: RENDER
// Every button on every screen against SkillRx's button rules (docs/design/design.md, "Buttons"),
// beyond the page header that button-audit.js covers. As each role, on every target:
//
//   - every button is one of the variants (primary, secondary, ghost, ghost-danger, danger)
//   - at most one primary on a page (a dialog's own buttons don't count)
//   - filled danger only on the button that carries out a destruction, inside a confirmation
//   - a destructive button (Delete, Remove, Revoke) is not red at rest, and is red on hover
//   - table row actions are ghost or ghost-danger, at the small size
//   - a form's action row starts with its primary
//   - nothing that changes data is a link (data-turbo-method on an <a>)
//   - buttons are 40px, or 32px at the small size
//
// Usage: node bin/design/button-rules-audit.js   (exit 1 on any finding)
const { chromium } = require("playwright");
const { targets, signIn, visit, RUNS, BUTTON_VARIANTS } = require("./targets");

(async () => {
  const browser = await chromium.launch();
  const findings = [];
  let buttons = 0, pages = 0;
  for (const [email, owns] of RUNS) {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    await signIn(page, email);
    for (const { path } of targets().filter((t) => owns(t.path) || RUNS[RUNS.length - 1][0] === email)) {
      if (!(await visit(page, path))) continue;
      pages++;
      const r = await page.evaluate(async (variants) => {
        const out = [];
        const sel = "a.button, button.button, input.button, a[class*='site-button'], button[class*='site-button']";
        const els = [...document.querySelectorAll(sel)].filter((el) => {
          const b = el.getBoundingClientRect();
          return b.width > 0 && b.height > 0 && !el.closest("dialog:not([open])");
        });
        const variantOf = (el) => { const c = ` ${el.className} `; const h = variants.find(([k]) => c.includes(k)); return h ? h[1] : "unknown"; };
        const label = (el) => (el.getAttribute("aria-label") || el.value || el.textContent).trim().replace(/\s+/g, " ").slice(0, 40);
        // Through a canvas, so oklch() and var() resolve to sRGB before judging.
        const ctx = document.createElement("canvas").getContext("2d", { willReadFrequently: true });
        const isRed = (color) => { ctx.clearRect(0, 0, 1, 1); ctx.fillStyle = "#000"; ctx.fillStyle = color; ctx.fillRect(0, 0, 1, 1);
          const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data; return r > 150 && r > g * 1.6 && r > b * 1.4; };
        const primaries = [];
        for (const el of els) {
          if (el.className.toString().includes("site-button")) continue; // the public home page's own set
          const v = variantOf(el), name = label(el), h = Math.round(el.getBoundingClientRect().height);
          const sm = el.classList.contains("button-sm");
          const destructive = /^(delete|remove|revoke)\b/i.test(name);
          const inConfirm = !!el.closest(".confirm-dialog, .inline-confirm");
          if (v === "unknown") out.push(`unknown variant: "${name}"`);
          if (v === "primary" && !el.closest("dialog")) primaries.push(name);
          if (v === "danger" && !inConfirm) out.push(`filled danger outside a confirmation: "${name}"`);
          if (destructive && !inConfirm) {
            if (v !== "ghost-danger") out.push(`destructive but ${v}: "${name}"`);
            if (isRed(getComputedStyle(el).color)) out.push(`destructive and red at rest: "${name}" (${getComputedStyle(el).color})`);
          }
          if (el.closest("tbody") && (!/ghost/.test(v) || !sm)) out.push(`row action not ghost/small: "${name}" (${v}${sm ? ", sm" : ""})`);
          if (h !== (sm ? 32 : 40)) out.push(`height ${h}px, expected ${sm ? 32 : 40}: "${name}"`);
        }
        if (primaries.length > 1) out.push(`${primaries.length} primaries: ${primaries.join(" | ")}`);
        for (const row of document.querySelectorAll(".form-actions")) {
          const first = row.querySelector(sel);
          if (first && variantOf(first) !== "primary") out.push(`form actions start with ${variantOf(first)}: "${label(first)}"`);
        }
        for (const a of document.querySelectorAll("a[data-turbo-method]:not([data-turbo-method=get])")) out.push(`a link changes data: "${label(a)}"`);
        // Hover a destructive ghost button: it should turn red.
        const ghost = els.find((el) => variantOf(el) === "ghost-danger");
        return { out, count: els.length, ghostSelector: ghost ? (ghost.id ? `#${ghost.id}` : null) : null };
      }, BUTTON_VARIANTS);
      buttons += r.count;
      for (const f of r.out) findings.push(`${email.split("@")[0].padEnd(6)} ${path.padEnd(22)} ${f}`);
    }
    // One hover check per role: a ghost-danger button turns red on hover.
    for (const { path } of targets()) {
      if (!(await visit(page, path))) continue;
      const btn = page.locator(".button-ghost-danger:visible").first();
      if (!(await btn.count())) continue;
      await btn.hover();
      const [color, m] = await btn.evaluate((el) => {
        const c = getComputedStyle(el).color, ctx = document.createElement("canvas").getContext("2d");
        ctx.fillStyle = c; ctx.fillRect(0, 0, 1, 1); return [c, [...ctx.getImageData(0, 0, 1, 1).data]];
      });
      if (!(m[0] > 150 && m[0] > m[1] * 1.6)) findings.push(`${email.split("@")[0].padEnd(6)} ${path.padEnd(22)} ghost-danger not red on hover (${color})`);
      break;
    }
    await page.close();
  }
  await browser.close();
  console.log(`${buttons} buttons on ${pages} screen visits`);
  findings.forEach((f) => console.log("  " + f));
  console.log(`${findings.length} finding(s)`);
  process.exit(findings.length ? 1 : 0);
})();
