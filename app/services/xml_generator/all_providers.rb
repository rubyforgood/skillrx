class XmlGenerator::AllProviders < XmlGenerator::SingleProvider
  def initialize(language, **args)
    @language = language
    @args = args
  end

  attr_reader :language, :args

  def xml_content(xml)
    language.providers
      .map do |provider|
        provider_xml(xml, provider)
      end
  end
end
