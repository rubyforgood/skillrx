import { Controller } from "@hotwired/stimulus"
import Tags from "bootstrap5-tags"

export default class extends Controller {
  static targets = ["language", "list"]
  connect() {
    Tags.init("select#topic_tag_list");
  }

  changeLanguage() {
    let languageId = this.languageTarget.value

    let url = `http://localhost:3001/tags?language_id=${languageId}`;

    fetch(url)
      .then((response) => response.text())
      .then(payload => JSON.parse(payload))
      .then(json => Object.fromEntries(json.map(({name}) => [name, name])))
      .then(data => this.presentTags(data))
  }

  presentTags(data) {
    let tagInstance = Tags.getInstance(this.listTarget)

    // tagInstance.resetSuggestions()
    // tagInstance.setData(data, false)
    Tags.init("select#topic_tag_list", {
      items: data
    }, true);
  }
}
