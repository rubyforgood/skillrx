module TaggingHelpers
  # Selects a tag in a form using the select-tags Stimulus controller
  #
  # @param tag_name [String] the name of the tag to be selected
  #
  # @example
  #   select_tag("ruby") # Enters the tag "ruby" in the form
  #
  # @note This helper assumes the presence of a Stimulus controller 'select-tags'
  #       which renders a specific DOM structure
  def select_tag(tag_name)
    within "div[data-controller='select-tags']" do
      tag_input = find("div.form-control.dropdown.form-select>div>input")
      tag_input.fill_in(with: tag_name)
      tag_input.send_keys(:enter)
    end
  end

  # Verifies that specific tags are present in a topic's detail page
  #
  # @param title [String] the title of the topic to check
  # @param expected_tags [Array<String>] list of tags that should be present
  #
  # @example
  #   verify_tags_in_topic_page("My Ruby Topic", ["ruby", "programming"])
  #
  # @note This helper navigates to the topic's show page for verification
  #       as tags are only visible in the detail view
  def verify_tags_in_topic_page(title, expected_tags)
    visit_with_wait(topic_path(Topic.find_by(title: title)))
    expected_tags.each do |tag|
      expect(page).to have_text(tag)
    end
  end
end
