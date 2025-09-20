class CsvGenerator::TagDetails < CsvGenerator::Base
  private

  def headers
    %w[TagID Tag]
  end

  def scope
    topics_collection.active.includes(:tags)
      .flat_map { |topic| topic.tags_on(language.code.to_sym) }
      .uniq
      .map do |tag|
        [
          tag.id,
          tag.name,
        ]
      end
  end
end
