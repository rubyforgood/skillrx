module Taggable
  extend ActiveSupport::Concern

  class LanguageContextError < StandardError; end

  included do
    acts_as_taggable_on :tags

    after_initialize do
      unless self.class.reflect_on_association(:language)
        raise "#{self.class} must define belongs_to :language to include Taggable"
      end
    end
  end

  # Retrieves associated tags
  #
  # @return [Array<Tag>] list of tags
  def current_tags
    tags
  end

  # Retrieves associated tags
  #
  # @return [Array<String>] list of tag names
  def current_tags_list
    all_tags_list
  end

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

  def process_tags(tag_names)
    return unless tag_names.present?

    Rails.logger.info "Processing tags: #{tag_names} for record: #{id}"
    removed_tags = current_tags_list - tag_names
    @full_list_of_tags = tag_names + removed_tags
    removed_tags_with_cognates = tags_with_cognates(removed_tags)
    tag_names_without_redundant_cognates = tag_names - removed_tags_with_cognates
    tag_names_with_cognates_to_add = tag_names_without_redundant_cognates + tags_with_cognates(tag_names_without_redundant_cognates)
    final_tag_names = tag_names_with_cognates_to_add.uniq.compact_blank

    # Once we have changed all context attributes to "tags", we can change this to tag_list = final_tag_names
    tag_list.add(final_tag_names)
    save!
    taggings.where(tag_id: Tag.where(name: removed_tags_with_cognates)).destroy_all
  end

  def cognates_names_for(tags_to_keep_add_or_remove)
    Tag.where(name: tags_to_keep_add_or_remove).each_with_object({}) do |tag, hash|
      hash[tag.name] = tag.cognates_tags.uniq.pluck(:name).push(tag.name)
    end
  end

  def tags_with_cognates(list)
    tag_cognates_map.slice(*list).values.flatten
  end

  def tag_cognates_map
    @tag_cognates_map ||= cognates_names_for(full_list_of_tags)
  end

  attr_reader :full_list_of_tags
end
