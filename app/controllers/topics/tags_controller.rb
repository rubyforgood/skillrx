class Topics::TagsController < ApplicationController
  before_action :set_topic

  def index
    return [] unless params[:topic_id].present? && tags_params[:language_id].present?

    @tags = @topic.current_tags_for_language(tags_params[:language_id])
    render json: @tags
  end

  private

  def tags_params
    params.permit(:language_id)
  end

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end
end
