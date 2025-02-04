class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive ]
  before_action :check_admin!, only: :destroy

  def index
    @topics = scope.includes(:language, :provider)
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

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def scope
    @scope ||= if Current.user.is_admin?
      Topic.all
    else
      Topic.active
    end
  end
end
