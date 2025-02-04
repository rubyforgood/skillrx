class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def check_admin!
    redirect_to root_path unless Current.user.is_admin?
  end

  def after_authentication_url
    if Current.user.is_admin?
      users_path
    else
      topics_path
    end
  end
end
