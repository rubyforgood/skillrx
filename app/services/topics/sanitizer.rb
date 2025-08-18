class Topics::Sanitizer
  def initialize(params:, provider:, provider_scope:)
    @params = params
    @provider = provider
    @provider_scope = provider_scope
  end

  def sanitize
    params
      .then { validate_provider!(_1) }
      .then { validate_published_at!(_1) }
      .then { validate_blobs!(_1) }
      .tap do |p|
        p["title"] = p["title"].strip if p["title"].present?
        p["description"] = p["description"].strip if p["description"].present?
      end
  end

  private

  def validate_provider!(params)
    return params if params["provider_id"].blank?

    params.tap do |p|
      p["provider_id"] = provider_scope.find(p["provider_id"]).id
      p["provider_id"] = provider.id if provider && !Current.user.is_admin?
    end
  end

  def validate_published_at!(params)
    year = params["published_at_year"].present? ? params["published_at_year"].to_i : Time.current.year
    month = params["published_at_month"].present? ? params["published_at_month"].to_i : Time.current.month

    params.tap do |p|
      p["published_at"] = DateTime.new(year, month, 1)
      p.delete("published_at_year")
      p.delete("published_at_month")
    end
  end

  def validate_blobs!(params)
    return params if params[:document_signed_ids].blank?

    params[:document_signed_ids] = params[:document_signed_ids].filter_map do |signed_id|
      blob = ActiveStorage::Blob.find_signed(signed_id)
      next if blob.blank?

      if blob.content_type.in?(Topic::CONTENT_TYPES) && blob.byte_size < 200.megabytes
        next signed_id
      end

      blob.purge
      nil
    end

    params
  end

  attr_accessor :params, :provider_scope, :provider
end
