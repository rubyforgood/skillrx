import { Controller } from "@hotwired/stimulus";
import Tags from "bootstrap5-tags";

export default class extends Controller {
  static targets = ["selectableList"];

  connect() {
    this.initializeSelectables();
  }

  /**
   * Initialize the input with given options
   * @param {Object} options - Configuration options for bootstrap5-tags
   */
  initializeSelectables(options = {}, reset = false) {
    Tags.init(`select#${this.selectableListTarget.id}`, options, reset);
  }
}
