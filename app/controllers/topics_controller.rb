class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive ]
  before_action :check_admin!, only: :destroy

  def index
    @topics = scope.search_with_params(search_params)
    @search = Topic::SEARCH.new(**search_params)
    @providers = scope.map(&:provider).uniq.sort_by(&:name)
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
    @topic.destroy
    redirect_to topics_path
  end

  def archive
    @topic.archived!
    redirect_to topics_path
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :description, :uid, :language_id, :provider_id)
  end

  def search_params
    default_search_params
      .then do |def_params|
        params[:search].present? ? def_params.merge(
          params.require(:search).permit(:query, :state, :provider_id, :language_id, :year, :month, :order).to_h.symbolize_keys,
        ) : def_params
      end
  end

  def default_search_params
    { query: nil, state: nil, provider_id: nil, language_id: nil, year: nil, month: nil, order: :desc }
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
