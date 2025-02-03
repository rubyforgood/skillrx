class UsersController < ApplicationController
  def index
    @users = User.all
    #users = User.all

  end

  def create

  end
  def new
  end
  def edit
  end
  def destroy
  end

end
