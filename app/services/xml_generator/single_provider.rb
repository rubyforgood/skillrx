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
    Ox::Element.new("content_provider").tap do |xml|
      xml[:name] = provider.name

      grouped_topics(provider).each do |(year, month), topics|
        xml << Ox::Element.new("topic_year").tap do |year_element|
          year_element[:year] = year.to_s
          year_element << Ox::Element.new("topic_month").tap do |month_element|
            month_element[:month] = month
            topics.each do |topic|
              month_element << Ox::Element.new("title").tap do |title_element|
                title_element[:name] = topic.title
                title_element << Ox::Element.new("topic_id").tap { |id| id << topic.id.to_s }
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

  def grouped_topics(prov)
    topic_scope(prov).group_by { |topic| [ topic.published_at.year, topic.published_at.strftime("%m_%B") ] }
  end

  def topic_scope(prov)
    scope = prov.topics
    scope = scope.where("published_at > ?", 1.month.ago) if args.fetch(:recent, false)
    scope
      .select(:id, :title, :published_at, :language_id, :provider_id)
      .includes(:language, taggings: :tag)  # eager-load language and taggings->tag
      .with_attached_documents              # eager-load Active Storage attachments + blobs
      .order(published_at: :desc)
  end
end
