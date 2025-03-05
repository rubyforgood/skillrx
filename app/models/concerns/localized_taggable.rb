module LocalizedTaggable
  extend ActiveSupport::Concern

  class LanguageContextError < StandardError; end

  included do
    acts_as_taggable_on :tags

    after_initialize do
      unless self.class.reflect_on_association(:language)
        raise "#{self.class} must define belongs_to :language to include LanguageTaggable"
      end
    end
  end

  # Returns the language-specific tag context based on code
  #
  # @return [Symbol] the language context for tagging
  # @raise [LanguageContextError] if language or code is not present
  def language_tag_context
    raise LanguageContextError, "Language must be present" if language.nil?
    raise LanguageContextError, "Language ISO code must be present" if !new_record? && language.code.blank?

    language.code.to_sym
  end

  # Retrieves all available tags for the current language context
  #
  # @return [ActiveRecord::Relation] collection of ActsAsTaggableOn::Tag
  def available_tags
    ActsAsTaggableOn::Tag.for_context(language_tag_context)
  end

  # Retrieves all available tags for the current language context
  #
  # @return [ActiveRecord::Relation] collection of ActsAsTaggableOn::Tag
  def current_tags
    tag_list_on(language_tag_context)
  end
end
