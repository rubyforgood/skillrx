import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";
import Tags from "bootstrap5-tags";

export default class extends Controller {
  static targets = ["tagList"];

  connect() {
    this.initializeTags();
  }

  notify() {
    this.dispatch("notify", {
      detail: {
        content: Array.from(this.tagListTarget.selectedOptions).map(
          (option) => option.value
        ),
      },
    });
  }

  /**
   * Initialize the tags input with given options
   * @param {Object} options - Configuration options for bootstrap5-tags
   */
  initializeTags(options = {}, reset = false) {
    Tags.init(`select#${this.tagListTarget.id}`, options, reset);
  }
}
