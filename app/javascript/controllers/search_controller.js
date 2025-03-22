import { Controller } from "@hotwired/stimulus";
import { useDebounce } from "stimulus-use";

export default class extends Controller {
  static targets = ["search"];
  static debounces = ["submit"];

  connect() {
    useDebounce(this, { wait: 300 });
  }

  submit() {
    this.searchTarget.requestSubmit();
  }
}
