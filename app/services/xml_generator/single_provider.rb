class XmlGenerator::SingleProvider < XmlGenerator::Base
  def initialize(provider, **args)
    @provider = provider
    @args = args
  end

  private

  attr_reader :provider, :args

  def xml_content(xml)
    provider_xml(xml, provider)
  end

  def provider_xml(xml, provider)
    xml.content_provider(name: provider.name) {
      grouped_topics(provider).each do |(year, month), topics|
        xml.topic_year(year: year) {
          xml.topic_month(month: month) {
            topics.each do |topic|
              xml.title(name: topic.title) {
                xml.topic_id topic.id
                xml.topic_files(files: "Files") {
                  topic.documents.each_with_index do |document, index|
                    xml.send("file_name_#{index + 1}", file_size: document.byte_size) {
                      xml.text! document.filename
                    }
                  end
                }
                xml.topic_tags topic.current_tags_list.join(", ")
              }
            end
          }
        }
      end
    }
  end

  def grouped_topics(prov)
    topic_scope(prov).group_by { |topic| [ topic.created_at.year, topic.created_at.strftime("%m_%B") ] }
  end

  def topic_scope(prov)
    return prov.topics.where("created_at > ?", 1.month.ago) if args.fetch(:recent, false)

    prov.topics
  end
end
