class XmlGenerator::Base
  def perform
    Ox.dump(builder)
  end

  private

  def builder
    Ox::Document.new.tap do |doc|
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = "1.0"
      doc << instruct

      xml = Ox::Element.new("cmes")
      xml_content(xml)
      doc << xml
    end
  end
end
