class XmlGenerator::Base
  def perform
    builder.to_xml
  end

  private

  def builder
    Nokogiri::XML::Builder.new do |xml|
      xml.cmes { xml_content(xml) }
    end
  end
end
