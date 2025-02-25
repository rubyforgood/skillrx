class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_provider
    @current_provider ||= begin
      Current.user.providers.find(cookies.signed[:current_provider_id])
    rescue ActiveRecord::RecordNotFound
      Current.user.providers.first
    end
  end
  helper_method :current_provider
end
