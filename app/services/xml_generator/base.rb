class XmlGenerator::Base
  def perform
    generate
  end

  private

  def generate
    Nokogiri::XML::Builder.new { xml_data(it) }.to_xml
  end
end
