import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "filesInput",
    "fileItem",
    "filesContainer",
    "hiddenField",
    "submitButton",
  ];

  uploadFile(event) {
    event.preventDefault();

    this.submitButtonTarget.classList.add("disabled");

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
          filesInput.value = "";
        }
      });

    this.submitButtonTarget.classList.remove("disabled");
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
