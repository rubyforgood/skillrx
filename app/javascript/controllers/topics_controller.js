import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {
  static targets = [ "searchForm", "chooseForm" ]
  static debounces = [ "search" ]

  connect() {
    useDebounce(this, { wait: 300 })
  }

  searchTopics() {
    this.searchFormTarget.requestSubmit()
  }

  chooseProvider() {
    this.chooseFormTarget.requestSubmit()
  }
}
