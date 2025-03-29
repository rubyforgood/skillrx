
class TagsController < ApplicationController
  before_action :set_tag, only: [ :show, :edit, :update, :destroy ]

  def index
    @tags = Tag.includes(:cognates, :reverse_cognates).references(:tag)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to tags_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @tag.update!(tag_params)
      redirect_to tags_path, notice: "Tag was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to tags_path and return unless Current.user.is_admin?
    @tag.destroy
    redirect_to tags_path, notice: "Tag was successfully destroyed."
  end

  private

  def tag_params
    params.require(:tag).permit(:name, cognates_list: [])
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
