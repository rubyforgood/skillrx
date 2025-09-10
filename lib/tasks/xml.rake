namespace :xml do
  desc "Generate CME XML to a local file or stdout (no Azure). ENV: SCOPE=all_providers|single_provider LANGUAGE=<id|code|name> PROVIDER_ID=<id> DEST=<path or '-'>"
  task generate: :environment do
    require "fileutils"

    scope = ENV.fetch("SCOPE", "all_providers")
    lang_param = ENV["LANGUAGE"]
    provider_id = ENV["PROVIDER_ID"]
    dest = ENV["DEST"] || "tmp/cmes.xml"

    language = if lang_param.present?
      Language.find_by(id: lang_param) || Language.find_by(code: lang_param) || Language.find_by(name: lang_param)
    else
      Language.joins(:topics).distinct.first
    end
    abort "LANGUAGE not found or no languages with topics" unless language

    service = case scope
    when "single_provider"
      abort "PROVIDER_ID required for single_provider" unless provider_id.present?
      provider = Provider.find(provider_id)
      XmlGenerator::SingleProvider.new(provider)
    when "all_providers"
      XmlGenerator::AllProviders.new(language)
    else
      abort "Unknown SCOPE: #{scope}"
    end

    xml = service.perform

    if dest == "-"
      puts xml
    else
      path = Rails.root.join(dest)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, xml)
      puts "Wrote XML to #{path} (#{xml.bytesize} bytes)"
    end
  end
end
