
class TagsController < ApplicationController
  def index
    @tags = ActsAsTaggableOn::Tag.for_context(language_tag_context)

    render json: @tags
  end

  private

  def tag_params
    params.permit(:language_id)
  end

  def language_tag_context
    Language.find(params[:language_id]).code.to_sym
  end
end
