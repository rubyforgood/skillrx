class XmlGenerator::AllProviders < XmlGenerator::SingleProvider
  def initialize(language, **args)
    @language = language
    @args = args
  end

  attr_reader :language, :args

  def xml_content(xml)
    language.providers.includes(:topics)
      .each do |provider|
        xml << provider_xml(provider)
      end
  end
end
