namespace :blobs do
  desc "Enqueue SHA256 checksum calculation for blobs missing one"
  task backfill_sha256: :environment do
    enqueued = 0

    ActiveStorage::Blob.where(sha256_checksum: nil).find_each do |blob|
      Blobs::ComputeSha256ChecksumJob.perform_later(blob.id)
      enqueued += 1
    end

    puts "Enqueued SHA256 backfill job for #{enqueued} blob(s)"
  end
end
