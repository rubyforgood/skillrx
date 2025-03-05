module Taggable
  extend ActiveSupport::Concern

  private

  def save_with_tags(record, params)
    tag_list_param = params.slice!(:tag_list)

    ActiveRecord::Base.transaction do
      if record.update(params)
        process_tags(record, tag_list_param[:tag_list])
        true
      else
        false
      end
    end
  end

  private

  def process_tags(record, tag_list)
    return unless tag_list.present?

    Rails.logger.info "Processing tags: #{tag_list} for record: #{record.id}"
    tags = tag_list.compact_blank.join(",")

    raise ArgumentError, "Invalid tags" unless valid_tags?(tags)
    record.set_tag_list_on(record.language.code.to_sym, tags)
    record.save!
  end

  def valid_tags?(tags) = true
end
