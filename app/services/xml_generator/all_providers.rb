class XmlGenerator::AllProviders < XmlGenerator::SingleProvider
  def initialize(language, **args)
    @language = language
    @args = args
  end

  attr_reader :language, :args

  def xml_content(xml)
    # Avoid building a massive join result; iterate provider ids in small slices.
    ActiveRecord::Base.uncached do
      provider_ids_in_language_in_batches do |ids|
        Provider.where(id: ids).order(:id).each do |provider|
          xml << provider_xml(provider) # provider_xml should eager-load topics/attachments per provider
        end
      end
    end
  end

  private

  # Yields slices of provider ids that have topics in this language.
  def provider_ids_in_language_in_batches(batch_size: 500)
    Topic.where(language_id: language.id).distinct.pluck(:provider_id).each_slice(batch_size) do |ids|
      yield ids
    end
  end
end
