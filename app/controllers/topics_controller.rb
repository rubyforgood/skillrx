class TopicsController < ApplicationController
  include Taggable

  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive ]

  def index
    @topics = scope.search_with_params(search_params)
    @available_providers = other_available_providers
    @languages = scope.map(&:language).uniq.sort_by(&:name)
  end

  def new
    @topic = scope.new
  end

  def create
    @topic = scope.new

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
      render :edit, status: :unprocessable_entity
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
    @tags = @topic.current_tags_for_language(topic_tags_params[:language_id])
    render json: @tags
  end

  private

  def other_available_providers
    return [] unless provider_scope.any?

    provider_scope.where.not(id: current_provider.id)
  end

  def topic_params
    params
      .require(:topic)
      .permit(:title, :description, :uid, :language_id, :provider_id, :published_at_year, :published_at_month, tag_list: [], documents: []).tap do |permitted_params|
        permitted_params = validate_provider!(permitted_params)
        permitted_params = validate_published_at!(permitted_params)
      end
  end

  def validate_provider!(attrs)
    if attrs["provider_id"].present?
      attrs["provider_id"] = provider_scope.find(attrs["provider_id"]).id
      attrs["provider_id"] = current_provider.id if current_provider && !Current.user.is_admin?
    end
    attrs
  end

  def validate_published_at!(attrs)
    if attrs["published_at_year"].present? && attrs["published_at_month"].present?
      attrs["published_at"] = DateTime.new(attrs["published_at_year"].to_i, attrs["published_at_month"].to_i, 1)
      attrs.delete("published_at_year")
      attrs.delete("published_at_month")
    end
    attrs
  end

  def topic_tags_params
    params.permit(:language_id)
  end

  def search_params
    return {} unless params[:search].present?

    params.require(:search).permit(:query, :state, :provider_id, :language_id, :year, :month, :order)
  end
  helper_method :search_params

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def scope
    @scope ||= if Current.user.is_admin?
      Topic.all
    elsif current_provider.present?
      current_provider.topics
    else
      Current.user.topics
    end.includes(:language, :provider)
  end

  def topics_title
    current_provider.present? ? "#{current_provider.name}/topics" : "Topics"
  end
  helper_method :topics_title
end
