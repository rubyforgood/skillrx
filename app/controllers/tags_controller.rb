
class TagsController < ApplicationController
  include Pagy::Backend

  before_action :set_tag, only: [ :show, :edit, :update, :destroy ]

  def index
    @pagy, @tags = pagy(Tag.includes(:cognates, :reverse_cognates).references(:tag).search_with_params(tag_search_params))
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

    if params[:confirmed]
      @tag.destroy
      redirect_to tags_path, notice: "Tag was successfully destroyed."
    else
      @confirmation_required = @tag.taggings_count.positive?
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, cognates_list: [])
  end

  def tag_search_params
    return {} unless params[:search].present?
    params.expect(search: [ :name, :order ])
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
