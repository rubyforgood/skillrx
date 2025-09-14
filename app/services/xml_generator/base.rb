class XmlGenerator::Base
  def perform
    Ox.dump(builder)
  end

  private

  def builder
    Ox::Document.new.tap do |doc|
      # Use the XML declaration as in your working file
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = "1.0"
      instruct[:encoding] = "UTF-8"
      instruct[:standalone] = "no"
      doc << instruct

      # Use CMES as the root element (all caps)
      xml = Ox::Element.new("CMES")
      xml_content(xml)
      doc << xml
    end
  end
end
