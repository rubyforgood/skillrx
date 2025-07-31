class JobsController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    return if Current.user&.is_admin?

    render plain: "Access denied", status: :forbidden
  end
end
