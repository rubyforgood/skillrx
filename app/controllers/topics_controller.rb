class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show, :edit, :tags, :update, :destroy, :archive ]

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
    validate_blobs

    if @topic.errors.none? && @topic.save_with_tags(topic_params)
      attach_files(document_signed_ids)
      redirect_to topics_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @documents = @topic.documents
  end

  def update
    validate_blobs

    if @topic.errors.none? && @topic.save_with_tags(topic_params)
      attach_files(document_signed_ids)
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

    @tags = @topic.current_tags_for_language(topic_tags_params[:language_id])
    render json: @tags
  end

  private

  def attach_files(signed_ids)
    return if signed_ids.blank?

    signed_ids.each do |signed_id|
      blob = ActiveStorage::Blob.find_signed(signed_id)
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
    year = attrs["published_at_year"].present? ? attrs["published_at_year"] : Time.current.year
    month = attrs["published_at_month"].present? ? attrs["published_at_month"] : Time.current.month
    attrs["published_at"] = DateTime.new(year, month, 1)
    attrs.delete("published_at_year")
    attrs.delete("published_at_month")
    attrs
  end

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
    end.includes(:language)
  end

  def topic_tags_params
    params.permit(:language_id)
  end

  def search_params
    return {} unless params[:search].present?

    params.require(:search).permit(:query, :state, :provider_id, :language_id, :year, :month, :order)
  end
  helper_method :search_params

  def topics_title
    current_provider.present? ? "#{current_provider.name}/topics" : "Topics"
  end
  helper_method :topics_title

  def validate_blobs
    blobs = document_signed_ids&.filter_map { |signed_id| ActiveStorage::Blob.find_signed(signed_id) }

    blobs&.each do |blob|
      unless blob.content_type.in?(Topic::CONTENT_TYPES) && blob.byte_size < 10.megabytes
        @topic.errors.add(:documents, "must be images, videos or PDFs of less than 10MB")
        blob.purge
      end
    end
  end
end
