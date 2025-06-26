class TopicSanitizer
  attr_accessor :params, :provider_scope, :current_provider

  def initialize(params, provider_scope, current_provider)
    @params = params
    @provider_scope = provider_scope
    @current_provider = current_provider
  end

  def sanitize
    params
      .then { validate_provider!(_1) }
      .then { validate_published_at!(_1) }
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
      p["provider_id"] = current_provider.id if current_provider && !Current.user.is_admin?
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
end
