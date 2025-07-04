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

  # Returns the language-specific tag context based on code
  #
  # @return [Symbol] the language context for tagging
  # @raise [LanguageContextError] if language or code is not present
  def language_tag_context
    return nil if new_record?

    raise LanguageContextError, "Language must be present" if language.nil?
    raise LanguageContextError, "Language code must be present" if language.code.blank?

    language.code.to_sym
  end

  # Retrieves all available tags for the current language context
  #
  # @return [ActiveRecord::Relation] collection of ActsAsTaggableOn::Tag
  def available_tags
    return [] if language_tag_context.nil?

    ActsAsTaggableOn::Tag.for_context(language_tag_context)&.order(name: :asc)
  end

  # Retrieves associated tags for the current language context
  #
  # @return [Array<Tag>] list of tags
  def current_tags
    return [] if language_tag_context.nil?

    tags_on(language_tag_context)
  end

  # Retrieves associated tags for the current language context
  #
  # @return [Array<String>] list of tag names
  def current_tags_list
    return [] if language_tag_context.nil?

    tag_list_on(language_tag_context)
  end

  # Retrieves associated tags for a specific language
  # @param language_id [Integer] the ID of the language
  # @return [ActiveRecord::Relation] collection of ActsAsTaggableOn::Tag
  def current_tags_for_language(language_id)
    return [] if language_id.nil?

    language = Language.find(language_id)

    tags_on(language.code.to_sym)
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
