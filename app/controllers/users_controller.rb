class UsersController < ApplicationController
  include Pagy::Backend

  before_action :redirect_contributors
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @pagy, @users = pagy(User.includes(:providers).search_with_params(user_search_params))

    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "user_list"
        else
          render :index
        end
      end
    end
  end

  def new
    @user = User.new
  end

  def show
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: "User was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
    end
  end

  private

  def set_user
    @user = User.includes(:providers).find(params.expect(:id))
  end

  def user_params
    params.expect(user: [ :email, :password, :is_admin,  provider_ids: [] ])
  end

  def user_search_params
    return {} unless params[:search].present?

    params.expect(search: [ :email, :is_admin, :order ])
  end
end
