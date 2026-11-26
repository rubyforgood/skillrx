class TopicsController < ApplicationController
  include ActiveStorage::SetCurrent
  include Pagy::Method

  before_action :set_topic, only: [ :show, :edit, :update, :destroy, :archive, :unarchive ]

  def index
    topics = list_scope.includes(:language, :documents_attachments)
    topics = topics.includes(:provider) if all_providers?
    @pagy, @topics = pagy(topics.search_with_params(search_params))
    @languages = Language.where(id: visible_topics.select(:language_id)).order(:name)
  end

  def new
    @topic = current_provider.topics.new
  end

  def create
    @topic = current_provider.topics.new(topic_params.except(:document_signed_ids))

    case mutator.create
    in [ :ok, _topic ]
      redirect_to topics_path, notice: "Topic was successfully created."
    in [ :error, errors ]
      @errors = errors
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def edit
    @documents = @topic.documents
  end

  def update
    case mutator.update
    in [ :ok, _topic ]
      redirect_to topics_path, notice: "Topic was successfully updated."
    in [ :error, errors ]
      @errors = errors
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    redirect_to topics_path and return unless Current.user.is_admin?

    if params[:confirmed]
      Topics::Mutator.new(topic: @topic).destroy
      redirect_to topics_path, notice: "Topic was successfully destroyed."
    else
      respond_to { |format| format.turbo_stream }
    end
  end

  def archive
    Topics::Mutator.new(topic: @topic).archive
    redirect_to topics_path, notice: "Topic was successfully archived."
  end

  def unarchive
    Topics::Mutator.new(topic: @topic).unarchive
    redirect_to topics_path, notice: "Topic was successfully reinstated."
  end

  private

  # The provider filter (docs/design/design.md, "Topics"). "all", or one provider's id, from the
  # `provider` param when the list form sends it, otherwise the choice remembered in a cookie.
  # Choosing one provider also makes it the default for a new topic (current_provider).
  # Clear filters links with provider=all, so it resets this like any other filter.
  def provider_filter
    @provider_filter ||= begin
      choice = params[:provider].presence || cookies.signed[:topics_provider].presence || "all"
      choice = "all" unless choice == "all" || provider_scope.exists?(id: choice)
      # Not on a Turbo prefetch: hovering a link (Clear filters) must not change what's remembered.
      if params[:provider].present? && request.headers["X-Sec-Purpose"] != "prefetch"
        cookies.signed[:topics_provider] = { value: choice, expires: 1.year }
        cookies.signed[:current_provider_id] = choice.to_i unless choice == "all"
      end
      choice
    end
  end
  helper_method :provider_filter

  def provider_choices
    @provider_choices ||= provider_scope.order(:name).to_a
  end
  helper_method :provider_choices

  # Show the field, and the Provider column under "All providers", only to people with more than one.
  def choosing_provider?
    provider_choices.size > 1
  end
  helper_method :choosing_provider?

  def all_providers?
    choosing_provider? && provider_filter == "all"
  end
  helper_method :all_providers?

  def visible_topics
    Topic.where(provider_id: provider_scope.select(:id))
  end

  def list_scope
    provider_filter == "all" ? visible_topics : visible_topics.where(provider_id: provider_filter)
  end

  def topic_params
    @topic_params ||= begin
      permitted_params = params
        .require(:topic)
        .permit(
          :title, :description, :uid, :language_id, :provider_id, :published_at_year, :published_at_month,
          tag_list: [], documents: [], document_signed_ids: [],
        )

      Topics::Sanitizer.new(params: permitted_params, provider: current_provider, provider_scope:).sanitize
    end
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  def mutator
    documents = topic_params.extract!(:document_signed_ids)
    document_signed_ids = documents[:document_signed_ids]

    @mutator ||= Topics::Mutator.new(
      topic: @topic,
      params: topic_params,
      document_signed_ids:,
    )
  end

  def search_params
    return { state: :active } unless params[:search].present?

    params.require(:search).permit(:query, :state, :language_id, :year, :month, :order, tag_list: [])
  end
  helper_method :search_params

  def topics_title
    return "Topics from all providers" if all_providers?

    provider = provider_choices.find { |p| p.id.to_s == provider_filter } || provider_choices.first
    provider ? "Topics from #{provider.name}" : "Topics"
  end
  helper_method :topics_title
end
