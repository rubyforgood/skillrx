class TopicsController < ApplicationController
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
    @topic = scope.new(topic_params)

    if @topic.save
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
    @topic.update(topic_params)
    redirect_to topics_path
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

  private

  def other_available_providers
    return [] unless Current.user.providers.any?

    Current.user.providers.where.not(id: current_provider.id)
  end

  def topic_params
    params
      .require(:topic)
      .permit(:title, :description, :uid, :language_id, :provider_id, documents: []).tap do |perm_params|
        if perm_params["provider_id"].present?
          perm_params["provider_id"] = Current.user.providers.find(perm_params["provider_id"]).id
          perm_params["provider_id"] = current_provider.id if current_provider && !Current.user.is_admin?
        end
      end
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
