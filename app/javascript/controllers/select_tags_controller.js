import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import Tags from "bootstrap5-tags"

export default class extends Controller {
  static targets = ["language", "tagList"]

  connect() {
    this.initializeTags()
  }

  /**
   * Handle language change event and update tags accordingly
   * @param {Event} event - Change event
   */
  async changeLanguage(event) {
    try {
      const { resourceId, languageId } = this.getIds()

      const tags = await this.fetchTags(languageId)
      const selectedTags = await this.fetchAssignedTags(languageId, resourceId)

      this.presentTags(tags, selectedTags)
    } catch (error) {
      console.error("Error changing language:", error)
    }
  }

  /**
   * Extract resource and language IDs from the form
   * @returns {Object} Object containing resourceId and languageId
   */
  getIds() {
    return {
      resourceId: this.languageTarget.dataset.resourceId,
      languageId: this.languageTarget.value
    }
  }

  /**
   * Fetch available tags for a given language
   * @param {string} languageId - ID of the selected language
   * @returns {Object} Dictionary of tag names
   */
  async fetchTags(languageId) {
    try {
      const response = await get(`/tags?language_id=${languageId}`, {
        responseKind: "json"
      })

      if (!response.ok) return []

      const json = await response.json
      return Object.fromEntries(json.map(({name}) => [name, name]))
    } catch (error) {
      console.error("Error fetching tags:", error)
      return []
    }
  }

  /**
   * Fetch tags already assigned to the resource
   * @param {string} languageId - ID of the selected language
   * @param {string} resourceId - ID of the current resource
   * @returns {string} Comma-separated list of tag names
   */
  async fetchAssignedTags(languageId, resourceId) {
    if (resourceId === undefined) return ""

    try {
      const response = await get(`/topics/${resourceId}/tags?language_id=${languageId}`, {
        responseKind: "json"
      })

      if (!response.ok) return ""

      const json = await response.json
      return json.map(x => x.name).join()
    } catch (error) {
      console.error("Error fetching assigned tags:", error)
      return ""
    }
  }

  /**
   * Update the tags input with new tags and selections
   * @param {Object} tags - Available tags
   * @param {string} selectedTags - Previously selected tags
   */
  presentTags(tags, selectedTags) {
    this.initializeTags({
      items: tags,
      selected: selectedTags
    }, true)
  }

  /**
   * Initialize the tags input with given options
   * @param {Object} options - Configuration options for bootstrap5-tags
   */
  initializeTags(options = {}, reset = false) {
    Tags.init(`select#${this.tagListTarget.id}`, options, reset)
  }
}
