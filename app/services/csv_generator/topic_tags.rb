class CsvGenerator::TopicTags < CsvGenerator::Base
  private

  def headers
    %w[TopicID TagID]
  end

  def scope
    topics_collection.active.includes(:tags)
      .flat_map do |topic|
        topic.tags_on(language.code.to_sym).map do |tag|
          [
            topic.id,
            tag.id,
          ]
        end
      end
  end
end
