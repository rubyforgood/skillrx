class XmlGenerator::SingleProvider < XmlGenerator::Base
  def initialize(provider, **args)
    @provider = provider
    @args = args
  end

  private

  attr_reader :provider, :args

  def xml_content(xml)
    xml << provider_xml(provider)
  end

  def provider_xml(provider)
    Ox::Element.new("Content_Provider").tap do |xml|
      xml[:name] = provider.name

      grouped_topics(provider).sort_by { |year, _| -year.to_i }.each do |(year, months)|
        xml << Ox::Element.new("topic_year").tap do |year_element|
          year_element[:year] = year.to_s
          months.sort_by { |month_label, _| month_label }.each do |(month, topics)|
            year_element << Ox::Element.new("topic_month").tap do |month_element|
              month_element[:month] = month
              topics.each do |topic|
                month_element << Ox::Element.new("title").tap do |title_element|
                  title_element[:name] = topic.title
                  title_element << Ox::Element.new("topic_id").tap { |id| id << topic.id.to_s }
                  title_element << Ox::Element.new("counter").tap { |c| c << "0" }
                  title_element << Ox::Element.new("topic_volume").tap { |e| e << topic.published_at.year.to_s }
                  title_element << Ox::Element.new("topic_issue").tap { |e| e << topic.published_at.month.to_s }
                  title_element << Ox::Element.new("topic_files").tap do |files|
                    files[:files] = "Files"
                    topic.documents.each_with_index do |document, index|
                      next if document.content_type == "video/mp4"
                      files << Ox::Element.new("file_name_#{index + 1}").tap do |file_name|
                        file_name << document.filename.to_s
                        file_name[:file_size] = document.byte_size
                      end
                    end
                  end
                  title_element << Ox::Element.new("topic_author").tap do |author|
                    author << Ox::Element.new("topic_author_1").tap { |a| a << " " }
                  end
                  title_element << Ox::Element.new("topic_tags").tap do |tags|
                    names = topic.taggings.map { |tg| tg.tag&.name }.compact.uniq
                    tags << names.join(", ")
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def grouped_topics(prov)
    # { year => { "MM_Month" => [topics] } }
    topic_scope(prov)
      .group_by { |topic| topic.published_at.year }
      .transform_values { |topics_in_year| topics_in_year.group_by { |t| t.published_at.strftime("%m_%B") } }
  end

  def topic_scope(prov)
  scope = prov.topics
  # When invoked from AllProviders, restrict topics to that language
  scope = scope.where(language_id: language.id) if respond_to?(:language) && language.present?
    scope = scope.where("published_at > ?", 1.month.ago) if args.fetch(:recent, false)
    scope
      .select(:id, :title, :published_at, :language_id, :provider_id)
      .includes(:language, taggings: :tag)
      .with_attached_documents
      .order(published_at: :desc)
  end
end
