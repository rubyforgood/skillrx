module Beacons
  class BaseController < ApplicationController
    before_action :redirect_contributors

    private

    def redirect_contributors
      redirect_to root_path, alert: "You don't have permission to access this page." unless Current.user&.is_admin?
    end
  end
end
