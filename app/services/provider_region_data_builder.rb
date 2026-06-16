class ProviderRegionDataBuilder
  def perform
    ProviderRegionDataJob.perform_later
  end
end
