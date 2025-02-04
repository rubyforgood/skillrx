class HomeController < ApplicationController
  allow_unauthenticated_access(only: :index)
  layout "home"
  def index
  end
end
