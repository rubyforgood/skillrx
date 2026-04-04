class BeaconsController < ApplicationController
  include Authentication

  before_action :set_beacon, only: %i[show edit update regenerate_key revoke_key]
  before_action :prepare_associations, only: %i[new edit]

  def index
    @beacons = Beacon.order(created_at: :desc)
  end

  def new
    @beacon = Beacon.new
  end

  def create
    success, @beacon, api_key = Beacons::Creator.new.call(beacon_params)

    if success
      flash[:notice] = "Beacon was successfully provisioned. API Key: #{api_key}"
      redirect_to beacon_path(@beacon, api_key: api_key)
    else
      prepare_associations
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @beacon.update(beacon_params)
      redirect_to @beacon, notice: "Beacon was successfully updated."
    else
      prepare_associations
      render :edit, status: :unprocessable_entity
    end
  end

  def regenerate_key
    _, api_key = Beacons::KeyRegenerator.new.call(@beacon)
    flash[:notice] = "API key has been successfully regenerated. API Key: #{api_key}"
    redirect_to beacon_path(@beacon, api_key: api_key)

    rescue => StandardError
      flash[:alert] = "API key could not be regenerated."
      redirect_to @beacon
  end

  def filter_options
    topics = if params[:language_id].present?
      Topic.active.where(language_id: params[:language_id]).order(:title)
    else
      Topic.active.order(:title)
    end

    providers = if params[:region_id].present?
      Provider.joins(:branches).where(branches: { region_id: params[:region_id] }).distinct.order(:name)
    else
      Provider.order(:name)
    end

    render json: {
      topics: topics.select(:id, :title),
      providers: providers.select(:id, :name),
    }
  end

  def revoke_key
    api_key = @beacon.revoke!
    flash[:notice] = "API key has been successfully revoked."
    redirect_to @beacon

    rescue => StandardError
      flash[:alert] = "API key could not be revoked."
      redirect_to @beacon
  end

  def non_contributor_redirect_path
    root_path
  end

  private

  def set_beacon
    @beacon = Beacon.find(params[:id])
  end

  def prepare_associations
    @languages = Language.order(:name)
    @providers = Provider.order(:name)
    @regions = Region.order(:name)
    @topics = Topic.active.order(:title)
  end

  def beacon_params
    params.require(:beacon).permit(:name, :language_id, :region_id, provider_ids: [], topic_ids: [])
  end
end
