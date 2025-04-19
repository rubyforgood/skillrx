class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def provider_scope
    @provider_scope ||= if Current.user.is_admin?
      Provider.all
    else
      Current.user.providers
    end
  end

  def current_provider
    @current_provider ||= begin
      provider_scope.find(cookies.signed[:current_provider_id])
    rescue ActiveRecord::RecordNotFound
      provider_scope.first || NullProvider.new
    end
  end
  helper_method :current_provider
end
