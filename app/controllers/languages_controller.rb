class LanguagesController < ApplicationController
  before_action :set_language, only: [ :edit, :update ]
  before_action :check_admin!

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(language_params)

    if @language.save
      redirect_to languages_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @language.update(language_params)
    redirect_to languages_path
  end

  private

  def language_params
    params.require(:language).permit(:name, :file_share_folder)
  end

  def set_language
    @language = Language.find(params[:id])
  end
end
