class TopicsController < ApplicationController
  include Taggable

  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive ]

  def index
    @topics = scope.search_with_params(search_params)
    @providers = scope.map(&:provider).uniq.sort_by(&:name)
    @languages = scope.map(&:language).uniq.sort_by(&:name)
  end

  def new
    @topic = scope.new
  end

  def create
    @topic = scope.new(topic_params)

    if save_with_tags(@topic, topic_params)
      redirect_to topics_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if save_with_tags(@topic, topic_params)
      redirect_to topics_path
    else
      render :edit
    end
  end

  def destroy
    redirect_to topics_path and return unless Current.user.is_admin?
    @topic.destroy
    redirect_to topics_path
  end

  def archive
    @topic.archived!
    redirect_to topics_path
  end

  def tags
    return [] unless params[:id].present? && topic_tags_params[:language_id].present?

    set_topic
    @tags = @topic.current_tags_for_context(topic_tags_params[:language_id])
    render json: @tags
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :description, :uid, :language_id, :provider_id, tag_list: [], documents: [])
  end

  def topic_tags_params
    params.permit(:language_id)
  end

  helper_method :search_params
  def search_params
    return {} unless params[:search].present?

    params.require(:search).permit(:query, :state, :provider_id, :language_id, :year, :month, :order)
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def scope
    @scope ||= if Current.user.is_admin?
      Topic.all
    else
      Current.user.topics
    end.includes(:language, :provider)
  end
end
