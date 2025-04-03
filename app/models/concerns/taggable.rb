module Taggable
  extend ActiveSupport::Concern

  # Updates the list of tags for a specific record
  # @param attrs [Array<String>] the list of tags
  # @return [Boolean] true if tags are processed successfully, false otherwise
  def save_with_tags(attrs)
    tag_list_param = attrs.extract!(:tag_list)

    ActiveRecord::Base.transaction do
      if update(attrs)
        process_tags(tag_list_param[:tag_list])
        true
      else
        false
      end
    end
  end

  private

  def process_tags(tag_list)
    return unless tag_list.present?

    Rails.logger.info "Processing tags: #{tag_list} for record: #{id}"
    tags = tag_list.compact_blank.join(",")

    raise ArgumentError, "Invalid tags" unless valid_tags?(tags)
    set_tag_list_on(language.code.to_sym, tags)
    save!
  end

  def valid_tags?(tags) = true
end
