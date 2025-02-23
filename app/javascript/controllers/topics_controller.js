import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = [ "form" ]
  static debounces = [ "search" ]

  connect() {
    useDebounce(this, { wait: 300 })
  }

  search() {
    this.formTarget.requestSubmit()
  }
}
