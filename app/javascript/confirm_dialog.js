// Every data-turbo-confirm in the app opens this in-app dialog instead of the browser's confirm()
// (design system design.md: "the app confirms, not the browser"). The dialog lives in the layouts
// (shared/_confirm_dialog). On the button or form, data-turbo-confirm is the question, and
// data-confirm-button (optional) labels the confirming button, e.g. "Delete region".
import { Turbo } from "@hotwired/turbo-rails"

Turbo.config.forms.confirm = (message, element, submitter) => {
  const dialog = document.getElementById("confirm-dialog")
  if (!dialog) return Promise.resolve(window.confirm(message))

  const source = submitter || element
  dialog.querySelector("[data-confirm-message]").textContent = message
  dialog.querySelector("[data-confirm-accept]").textContent =
    source?.dataset?.confirmButton || element?.dataset?.confirmButton || "Confirm"
  dialog.returnValue = ""
  dialog.showModal()
  dialog.querySelector("[data-confirm-cancel]").focus()

  return new Promise((resolve) => {
    dialog.addEventListener("close", () => resolve(dialog.returnValue === "accept"), { once: true })
  })
}
