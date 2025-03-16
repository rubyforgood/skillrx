class XmlGenerator::AllProviders < XmlGenerator::SingleProvider
  def initialize(providers)
    @providers = providers
  end

  attr_reader :providers

  def xml_content(xml)
    providers.map do |provider|
      provider_xml(xml, provider)
    end
  end
end
