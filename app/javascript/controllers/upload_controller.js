import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { documentId: Number };

  static targets = ["filesInput", "fileItem", "filesContainer"];

  uploadFile(event) {
    event.preventDefault();

    const filesInput = this.filesInputTarget;
    let files = Array.from(filesInput.files);

    let formData = new FormData();

    if (this.hasTopicIdValue) {
      formData.set("topic_id", this.topicIdValue);
    }

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
        }
      });
  }
}
