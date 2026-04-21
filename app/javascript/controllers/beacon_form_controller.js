import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["languageSelect", "regionSelect", "topicsSelect", "providersSelect"]
  static values = { filterUrl: String }

  connect() {
    // Defer until select-tags children have initialized their TomSelect instances
    requestAnimationFrame(() => this.fetchOptions())
  }

  fetchOptions() {
    const params = new URLSearchParams()
    const languageId = this.languageSelectTarget.value
    const regionId = this.regionSelectTarget.value

    if (languageId) params.set("language_id", languageId)
    if (regionId) params.set("region_id", regionId)

    get(`${this.filterUrlValue}?${params}`, { responseKind: "json" })
      .then(response => response.json)
      .then(data => {
        this.#updateSelect(this.topicsSelectTarget, data.topics, "title")
        this.#updateSelect(this.providersSelectTarget, data.providers, "name")
      })
  }

  #updateSelect(selectElement, items, textKey) {
    const tomSelect = selectElement.tomselect
    if (!tomSelect) return

    const previousValues = [].concat(tomSelect.getValue())

    tomSelect.clear(true)
    tomSelect.clearOptions()

    items.forEach(item => {
      tomSelect.addOption({ value: String(item.id), text: item[textKey] })
    })

    const stillValidValues = previousValues.filter(v =>
      items.some(item => String(item.id) === v)
    )
    if (stillValidValues.length > 0) {
      tomSelect.setValue(stillValidValues, true)
    }

    tomSelect.refreshOptions(false)
  }
}
