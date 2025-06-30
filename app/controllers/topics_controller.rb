class TopicsController < ApplicationController
  include ActiveStorage::SetCurrent
  include Pagy::Backend

  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive ]

  def index
    @pagy, @topics = pagy(scope.includes(:documents_attachments).search_with_params(search_params))
    @available_providers = other_available_providers
    @languages = scope.map(&:language).uniq.sort_by(&:name)
  end

  def new
    @topic = scope.new
  end

  def create
    document_signed_ids = topic_params.extract!(:document_signed_ids)
    @topic = scope.new(topic_params)
    return render :new, status: :unprocessable_entity if @topic.errors.any? || !@topic.save_with_tags(topic_params)

    attach_files(document_signed_ids[:document_signed_ids])
    redirect_to topics_path
  end

  def show
  end

  def edit
    @documents = @topic.documents
  end

  def update
    document_signed_ids = topic_params.extract!(:document_signed_ids)
    return render :edit, status: :unprocessable_entity if @topic.errors.any? || !@topic.save_with_tags(topic_params)

    attach_files(document_signed_ids[:document_signed_ids])
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

  def attach_files(signed_ids)
    return if signed_ids.blank?

    signed_ids.each do |signed_id|
      @topic.documents.attach(signed_id)
    end
  end

  def other_available_providers
    return [] unless provider_scope.any?

    provider_scope.where.not(id: current_provider.id)
  end

  def topic_params
    @topic_params ||= begin
      permitted_params = params
        .require(:topic)
        .permit(
          :title, :description, :uid, :language_id, :provider_id, :published_at_year, :published_at_month,
          tag_list: [], documents: [], document_signed_ids: [],
        )

      TopicSanitizer.new(params: permitted_params, provider: current_provider, provider_scope:).sanitize
    end
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def scope
    @scope ||= current_provider.topics.includes(:language)
  end

  def search_params
    return {} unless params[:search].present?

    params.require(:search).permit(:query, :state, :language_id, :year, :month, :order, tag_list: [])
  end
  helper_method :search_params

  def topics_title
    current_provider.present? ? "#{current_provider.name}/topics" : "Topics"
  end
  helper_method :topics_title
end
