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
    @topic = scope.new(topic_params)
    validate_blobs
    return render :new, status: :unprocessable_entity if @topic.errors.any? || !@topic.save_with_tags(topic_params)

    attach_files(document_signed_ids)
    redirect_to topics_path
  end

  def show
  end

  def edit
    @documents = @topic.documents
  end

  def update
    validate_blobs
    return render :edit, status: :unprocessable_entity if @topic.errors.any? || !@topic.save_with_tags(topic_params)

    attach_files(document_signed_ids)
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
      ActiveStorage::Blob.find_signed(signed_id)
      @topic.documents.attach(signed_id)
    end
  end

  def document_signed_ids
    params.dig(:topic, :document_signed_ids)
  end

  def other_available_providers
    return [] unless provider_scope.any?

    provider_scope.where.not(id: current_provider.id)
  end

  def topic_params
    permitted_params = params
      .require(:topic)
      .permit(:title, :description, :uid, :language_id, :provider_id, :published_at_year, :published_at_month, tag_list: [], documents: [])

    TopicSanitizer.new(permitted_params, provider_scope, current_provider).sanitize
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

  def validate_blobs
    return if document_signed_ids.blank?

    blobs = document_signed_ids.filter_map { |signed_id| ActiveStorage::Blob.find_signed(signed_id) }
    return if blobs.blank?

    blobs.each do |blob|
      next if blob.content_type.in?(Topic::CONTENT_TYPES) && blob.byte_size < 10.megabytes

      @topic.errors.add(:documents, "must be images, videos or PDFs of less than 10MB")
      blob.purge
    end
  end
end
