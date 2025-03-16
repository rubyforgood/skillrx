class XmlGenerator::SingleProvider < XmlGenerator::Base
  def initialize(provider)
    @provider = provider
  end

  private

  attr_reader :provider

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
                xml.counter 0
                xml.topic_volume topic.created_at.year
                xml.topic_issue 0
                xml.topic_files(files: "Files") {
                  topic.documents.each_with_index do |document, index|
                    xml.send("file_name_#{index + 1}", file_size: document.byte_size) {
                      xml.text! document.filename
                    }
                  end
                }
              }
            end
          }
        }
      end
    }
  end

  def grouped_topics(prov)
    prov.topics.group_by { |topic| [ topic.created_at.year, topic.created_at.strftime("%m_%B") ] }
  end
end
