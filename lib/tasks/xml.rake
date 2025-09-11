namespace :xml do
  desc "Generate CME XML to a local file or stdout (no Azure). ENV: SCOPE=all_providers|single_provider LANGUAGE=<id|code|name> PROVIDER_ID=<id> DEST=<path or '-'>"
  task generate: :environment do
    require "fileutils"

    scope = ENV.fetch("SCOPE", "all_providers")
    lang_param = ENV["LANGUAGE"]
    provider_id = ENV["PROVIDER_ID"]
  dest = ENV["DEST"] || "tmp/all_providers_test.xml"

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
  File.write(path, xml.encode("UTF-8", invalid: :replace, undef: :replace, replace: "�"), mode: "w:utf-8")
      puts "Wrote XML to #{path} (#{xml.bytesize} bytes)"

      # Upload to Azure using FileWorker
      require_relative "../../app/services/file_worker"
      share = ENV["AZURE_STORAGE_SHARE_NAME"]
      name = File.basename(path)
      azure_path = "" # root directory in Azure
      file_content = File.binread(path)

      FileWorker.new(
        share: share,
        name: name,
        path: azure_path,
        file: file_content
      ).send

      puts "Uploaded #{name} to Azure File Share #{share} (root directory)"
    end
  end
end
