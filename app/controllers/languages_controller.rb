class LanguagesController < ApplicationController
  before_action :redirect_contributors
  before_action :set_language, only: [ :edit, :update ]

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(language_params)

    if @language.save
      redirect_to languages_path, notice: "Language was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    @language.update(language_params)
    redirect_to languages_path, notice: "Language was successfully updated."
  end

  private

  def language_params
    params.require(:language).permit(:name)
  end

  def set_language
    @language = Language.find(params[:id])
  end
end
