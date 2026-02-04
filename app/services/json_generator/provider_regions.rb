class JsonGenerator::ProviderRegions < JsonGenerator::Base
  def initialize(language, **args)
    @language = language
    @args = args
  end

  private

  attr_reader :language, :args

  def json_content
    scope
      .map { |provider| { name: provider.name, prefix: provider.file_name_prefix, regions: provider.regions } }
      .to_json
  end

  def scope
    language.providers.includes(:regions)
  end
end
