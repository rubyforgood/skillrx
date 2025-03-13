class XmlGenerator::SingleProvider < XmlGenerator::Base
  def initialize(provider)
    @provider = provider
  end

  private

  attr_reader :provider

  def xml_data(xml)
    xml.root {
      xml.provider {
        xml.name provider.name
        xml.type provider.provider_type
      }
      xml.topics {
        provider.topics.each do |topic|
          xml.topic {
            xml.title topic.title
            xml.description topic.description
            xml.state topic.state
            xml.uid topic.uid
          }
        end
      }
    }
  end
end
