import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "filesInput",
    "fileItem",
    "filesContainer",
    "hiddenField",
    "submitButton",
    "errorMessage",
  ];

  uploadFile(event) {
    event.preventDefault();

    this.submitButtonTarget.disabled = true;
    this.submitButtonTarget.classList.add("disabled:opacity-75");
    this.submitButtonTarget.value = "Uploading...";
    this.showError("");

    const filesInput = this.filesInputTarget;
    let files = Array.from(filesInput.files);

    let formData = new FormData();

    files.forEach((file) => {
      formData.append("documents[]", file);
    });

    fetch("/uploads", {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          ?.getAttribute("content"),
      },
    })
      .then((response) => {
        return response.json();
      })
      .then((data) => {
        if (data.result === "success") {
          this.filesContainerTarget.innerHTML += data.html;
        } else {
          this.showError(data.message || "The upload failed. Please try again.");
        }
      })
      .catch(() => {
        this.showError("The upload failed. Please try again.");
      })
      .finally(() => {
        filesInput.value = "";
        this.submitButtonTarget.disabled = false;
        this.submitButtonTarget.classList.remove("disabled:opacity-75");
        this.submitButtonTarget.value = "Save Topic";
      });
  }

  showError(message) {
    if (!this.hasErrorMessageTarget) return;

    this.errorMessageTarget.textContent = message;
    this.errorMessageTarget.hidden = !message;
  }

  removeFile(event) {
    event.preventDefault();

    const signedId = event.currentTarget.dataset.signedId;

    fetch(`/uploads/${signedId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          ?.getAttribute("content"),
      },
    })
      .then((response) => {
        return response.json();
      })
      .then((data) => {
        if (data.result === "success") {
          const targetToRemove = this.fileItemTargets.find(
            (t) => t.dataset.signedId === signedId
          );
          if (targetToRemove) {
            targetToRemove.remove();
          }
          const hiddenFieldToRemove = this.hiddenFieldTargets.find(
            (t) => t.defaultValue === signedId
          );
          if (hiddenFieldToRemove) {
            hiddenFieldToRemove.remove();
          }
        }
      });
  }
}
