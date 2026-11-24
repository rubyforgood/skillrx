import { Controller } from "@hotwired/stimulus"

// A button that shows and hides one panel: the home page's menu on small screens.
// <div data-controller="disclosure">
//   <button data-disclosure-target="button" data-action="disclosure#toggle" aria-expanded="false" aria-controls="x">
//   <div id="x" data-disclosure-target="panel" hidden>
export default class extends Controller {
  static targets = ["button", "panel"]

  toggle() {
    const open = this.buttonTarget.getAttribute("aria-expanded") !== "true"
    this.buttonTarget.setAttribute("aria-expanded", String(open))
    this.panelTarget.hidden = !open
  }

  // Following a link inside the panel closes it.
  close() {
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.panelTarget.hidden = true
  }
}
