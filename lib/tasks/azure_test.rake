namespace :azure do
  desc "A basic Azure test task"
  task :test do
    puts "Running Azure test task..."
    require "azure/storage/file"
    require "rest-client"

    storage_account_name = "#{ENV['AZURE_STORAGE_ACCOUNT']}"
    storage_account_key = "#{ENV['AZURE_STORAGE_KEY']}"
    share_name = "#{ENV['AZURE_STORAGE_CONTAINER']}"

    storage_account = Azure::Storage::File::FileService.create(storage_account_name: storage_account_name, storage_access_key: storage_account_key)

    puts "Shares:"
    storage_account.list_shares.each do |share|
      puts share.name
    end

    puts "

    "

    puts "Files:"
    storage_account.list_directories_and_files(share_name, "/").each do |file|
      puts file.name
    end
  end
end
