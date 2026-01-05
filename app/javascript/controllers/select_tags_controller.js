import { Controller } from "@hotwired/stimulus";
import { get } from "@rails/request.js";
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["tagList"];

  connect() {
    this.initializeTags();
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
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
   * Initialize the tags input with Tom Select
   * @param {Object} options - Configuration options for Tom Select
   */
  initializeTags(options = {}) {
    const allowClear = this.tagListTarget.dataset.allowClear === "true";
    const allowNew = this.tagListTarget.dataset.allowNew === "true";

    const defaultOptions = {
      plugins: {
        remove_button: allowClear
          ? {
              title: "Remove this item",
            }
          : false,
      },
      create: allowNew,
      maxOptions: null,
      closeAfterSelect: false,
      hideSelected: true,
      onItemAdd: function () {
        // Clear the input after selecting a tag
        this.setTextboxValue("");
        this.refreshOptions(false);
      },
      render: {
        no_results: function (data, escape) {
          return '<div class="no-results">No results found</div>';
        },
      },
    };

    const mergedOptions = { ...defaultOptions, ...options };

    this.tomSelect = new TomSelect(this.tagListTarget, mergedOptions);
  }
}
