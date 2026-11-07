namespace :reconcile do
  desc <<~DESC.squish
    Read-only report of discrepancies between topics, their documents, ActiveStorage and the Azure File Share.
    ENV: LANGUAGE=<id|name> (default all), SKIP_BLOB_CHECK=1 (skip checking each file exists in storage),
    DEST=<path> (default tmp/reconciliation-<timestamp>.csv) or DEST=- to print the CSV to stdout.
  DESC
  task azure: :environment do
    share = ENV.fetch("AZURE_STORAGE_SHARE_NAME")
    languages = if ENV["LANGUAGE"].present?
      Language.where(id: ENV["LANGUAGE"]).or(Language.where(name: ENV["LANGUAGE"])).to_a.presence or abort "LANGUAGE not found"
    else
      Language.order(:name).to_a
    end
    dest = ENV["DEST"].presence || Rails.root.join("tmp", "reconciliation-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv").to_s

    warn "Reconciling share #{share} for #{languages.map(&:name).join(', ')}"
    report = AzureReconciliation::Report.new(
      lister: AzureReconciliation::DirectoryLister.new(share:),
      languages:,
      check_blobs: ENV["SKIP_BLOB_CHECK"].blank?,
    )

    if dest == "-"
      $stdout.write(report.to_csv)
    else
      File.write(dest, report.to_csv)
      warn "Wrote #{report.rows.size} rows to #{dest}"
    end

    warn "\nSummary (language, category, count):"
    report.summary.each { |(language, category), count| warn format("  %-20s %-25s %6d", language, category, count) }
    warn "  No discrepancies found." if report.summary.empty?
  end
end
