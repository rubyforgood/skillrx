import { Controller } from "@hotwired/stimulus"

// Submits the form when a field changes. The Jobs engine's filters use it (data-controller="form");
// the engine shipped this controller in its own importmap, which the SkillRx shell replaces.
export default class extends Controller {
  submit(event) {
    const form = event.target.form || event.target.closest("form")
    if (form) form.requestSubmit()
  }
}
