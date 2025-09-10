class LanguageTopicsXmlGenerator
  def initialize(language, provider: nil, **args)
    @language = language
    @provider = provider
    @args = args
  end

  def perform
    doc = Ox::Document.new(version: "1.0")
    root = Ox::Element.new("cmes")
    doc << root

    grouped_by_provider.each do |provider, topics|
      root << provider_xml(provider, topics)
    end

    Ox.dump(doc)
  end

  private

  attr_reader :language, :provider, :args

  def grouped_by_provider
    topics_scope.group_by(&:provider)
  end

  def provider_xml(provider, topics)
    Ox::Element.new("content_provider").tap do |provider_element|
      provider_element[:name] = provider.name
      build_year_nodes(provider_element, topics)
    end
  end

  def build_year_nodes(parent_element, topics)
    topics.group_by { |t| t.published_at.year }
          .sort_by { |year, _| -year }
          .each do |year, topics_in_year|
      parent_element << year_xml(year, topics_in_year)
    end
  end

  def year_xml(year, topics_in_year)
    Ox::Element.new("topic_year").tap do |year_element|
      year_element[:year] = year.to_s
      topics_in_year.group_by { |t| t.published_at.strftime("%m_%B") }
                    .sort_by { |month_label, _| month_label }
                    .each do |month_label, topics_in_month|
        year_element << month_xml(month_label, topics_in_month)
      end
    end
  end

  def month_xml(month_label, topics_in_month)
    Ox::Element.new("topic_month").tap do |month_element|
      month_element[:month] = month_label
      topics_in_month.each { |topic| month_element << topic_xml(topic) }
    end
  end

  def topic_xml(topic)
    Ox::Element.new("title").tap do |title_element|
      title_element[:name] = topic.title
      title_element << (Ox::Element.new("topic_id") << topic.id.to_s)
      title_element << (Ox::Element.new("counter") << "0")
      title_element << (Ox::Element.new("topic_volume") << topic.published_at.year.to_s)
      title_element << (Ox::Element.new("topic_issue") << topic.published_at.month.to_s)
      title_element << files_xml(topic.documents)
      title_element << (Ox::Element.new("topic_author") << (Ox::Element.new("topic_author_1") << " "))
      title_element << (Ox::Element.new("topic_tags") << topic.current_tags_list.join(", "))
    end
  end

  def files_xml(documents)
    Ox::Element.new("topic_files").tap do |files|
      files[:files] = "Files"
      documents.reject { |doc| doc.content_type == "video/mp4" }
               .each_with_index do |document, index|
        files << Ox::Element.new("file_name_#{index + 1}").tap do |file_name|
          file_name[:file_size] = document.byte_size
          file_name << document.filename.to_s
        end
      end
    end
  end

  def topics_scope
    scope = @provider ? @provider.topics : Topic
    scope = scope.where(language_id: language.id)

    scope = scope.where("published_at > ?", 1.month.ago) if args.fetch(:recent, false)

    scope.includes(:provider, { taggings: :tag }, { documents_attachments: :blob })
         .order(published_at: :desc)
  end
end
