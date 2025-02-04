class TopicsController < ApplicationController
  before_action :set_topic, only: %i[show edit update destroy]
  before_action :authenticate_user!
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @topics = Topic.all
  end

  def show
  end

  def new
    @topic = Topic.new
  end

  def edit
  end

  def create
    @topic = Topic.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: "Topic was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: "Topic was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @topic.destroy!

    respond_to do |format|
      format.html { redirect_to topics_path, status: :see_other, notice: "Topic was successfully destroyed." }
    end
  end

  private

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:title, :description, :language_id, :provider_id, :archived)
  end

  def authorize_user!
    redirect_to topics_path, alert: "You are not authorized to perform this action." unless current_user == @topic.provider.user
  end
end
