class BeaconsController < ApplicationController
  before_action :redirect_contributors
  before_action :set_beacon, only: %i[show edit update]

  def index
    @beacons = Beacon.includes(:language, :region, :providers, :topics).order(created_at: :desc)
  end

  def new
    @beacon = Beacon.new
    @languages = Language.order(:name)
    @providers = Provider.order(:name)
    @regions = Region.order(:name)
    @topics = Topic.order(:name)
  end

  def create
    success, @beacon, api_key = Beacons::Creator.new.call(beacon_params)
    
    if success
      flash[:notice] = "Beacon was successfully provisioned. API Key: #{api_key}"
      flash[:api_key] = api_key
      redirect_to @beacon
    else
      @languages = Language.order(:name)
      @providers = Provider.order(:name)
      @regions = Region.order(:name)
      @topics = Topic.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @api_key_display = flash[:api_key]
  end

  def edit
    @languages = Language.order(:name)
    @providers = Provider.order(:name)
    @regions = Region.order(:name)
    @topics = Topic.order(:name)
  end

  def update
    if @beacon.update(beacon_update_params)
      redirect_to @beacon, notice: "Beacon was successfully updated."
    else
      @languages = Language.order(:name)
      @providers = Provider.order(:name)
      @regions = Region.order(:name)
      @topics = Topic.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_beacon
    @beacon = Beacon.find(params[:id])
  end

  def beacon_params
    params.require(:beacon).permit(:name, :language_id, :region_id, provider_ids: [], topic_ids: [])
  end

  def beacon_update_params
    params.require(:beacon).permit(:name, :language_id, :region_id, provider_ids: [], topic_ids: [])
  end

  def redirect_contributors
    redirect_to root_path, alert: "You don't have permission to access this page." unless Current.user&.is_admin?
  end
end
