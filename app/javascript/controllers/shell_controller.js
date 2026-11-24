import { Controller } from "@hotwired/stimulus"

// The app shell (docs/design/design.md, "App shell"): opens and closes nav groups, and the
// off-canvas navigation drawer below the `lg` breakpoint.
export default class extends Controller {
  static targets = ["drawer", "openButton"]

  toggleGroup(event) {
    const button = event.currentTarget
    const open = button.getAttribute("aria-expanded") !== "true"
    button.setAttribute("aria-expanded", String(open))
    document.getElementById(button.getAttribute("aria-controls")).hidden = !open
  }

  openDrawer() {
    this.drawerTarget.dataset.open = "true"
    this.openButtonTarget.setAttribute("aria-expanded", "true")
    this.drawerTarget.querySelector("a, button")?.focus()
  }

  closeDrawer() {
    if (this.drawerTarget.dataset.open !== "true") return
    delete this.drawerTarget.dataset.open
    this.openButtonTarget.setAttribute("aria-expanded", "false")
    this.openButtonTarget.focus()
  }

  // Escape closes the drawer, the same as clicking the backdrop.
  keydown(event) {
    if (event.key === "Escape") this.closeDrawer()
  }
}
