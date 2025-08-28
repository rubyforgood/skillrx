class XmlGenerator::AllProviders < XmlGenerator::SingleProvider
  def initialize(language, **args)
    @language = language
    @args = args
  end

  attr_reader :language, :args

  def xml_content(xml)
    language.providers
      .select("providers.id, providers.name, topics.id AS topic_id, topics.title AS topic_title, topics.created_at AS topic_created_at")
      .joins(:topics)
      .merge(Topic.with_attached_documents)
      .each do |provider|
        xml << provider_xml(provider)
      end
  end
end
