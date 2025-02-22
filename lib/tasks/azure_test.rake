namespace :azure do
  desc "A basic Azure test task"
  task :test do
    puts "Running Azure test task..."
    require "azure/storage/blob"
    require "rest-client"

    storage_account_name = "#{ENV['AZURE_STORAGE_ACCOUNT']}"
    storage_account_key = "#{ENV['AZURE_STORAGE_KEY']}"
    container_name = "#{ENV['AZURE_STORAGE_CONTAINER']}"

    base_url = "https://#{storage_account_name}.blob.core.windows.net/#{container_name}"

    client = Azure::Storage::Blob::BlobService.create(
      storage_account_name: storage_account_name,
      storage_access_key: storage_account_key,
    )

    sas_generator = Azure::Storage::Common::Core::Auth::SharedAccessSignature.new(storage_account_name, storage_account_key)

    sas_token = sas_generator.generate_service_sas_token(
      container_name,
      service: "b",  # Blob service
      resource: "c",  # Container
      permissions: "r",  # Read permission
      expiry: (Time.now + 3600).utc.iso8601,  # Expiry time (e.g., 1 hour from now)
    )

    sas_url = "#{base_url}?#{sas_token}"

    response = RestClient.get(sas_url)
    puts "Files in share:"
    JSON.parse(response.body)["file_list"].each do |file|
      puts file["name"]
    end
  end
end
