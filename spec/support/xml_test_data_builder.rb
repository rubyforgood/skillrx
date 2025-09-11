module XmlTestDataBuilder
  def self.xml_scenario
    Builder.new
  end
  class Builder
    def initialize
      @language = nil
      @provider = nil
      @topics_to_create = []
    end

    def for_language(name:)
      @language = Language.find_by(name: name) || FactoryBot.create(:language, name: name)
      self
    end

    def for_provider(name:, provider_type: "provider", file_name_prefix: "prefix")
      @provider = Provider.find_by(name:) || FactoryBot.create(:provider, name: name, file_name_prefix: file_name_prefix, provider_type: provider_type)
      self
    end

    def with_topic(title:, published_at:, tags: [], documents: [])
      raise "Provider must be set first with .for_provider" unless @provider
      @topics_to_create << {
        title:,
        published_at:,
        tags:,
        documents:,
        provider: @provider,
      }
      self
    end

    def build!
      raise "Language must be set first with .for_language" unless @language

      @topics_to_create.each do |topic_def|
        topic = FactoryBot.create(
          :topic,
          title: topic_def[:title],
          published_at: topic_def[:published_at],
          provider: topic_def[:provider],
          language: @language
        )

        topic.set_tag_list_on(@language.code, topic_def[:tags]) if topic_def[:tags].any?

        topic_def[:documents].each do |doc_def|
          file_path = Rails.root.join("spec", "fixtures", "files", doc_def[:filename])
          topic.documents.attach(
            io: File.open(file_path),
            filename: doc_def[:filename],
            content_type: doc_def[:content_type]
          )
        end
        topic.save!
      end
    end
  end
end
