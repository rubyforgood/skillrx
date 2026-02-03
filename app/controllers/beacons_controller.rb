class BeaconsController < ApplicationController
  before_action :redirect_contributors
  before_action :set_beacon, only: %i[show edit update]

  def index
    @beacons = Beacon.includes(:language, :provider, :region, :tags).order(created_at: :desc)
  end

  def new
    @beacon = Beacon.new
    @languages = Language.order(:name)
    @providers = Provider.order(:name)
    @regions = Region.order(:name)
    @tags = Tag.order(:name)
  end

  def create
    @beacon = Beacon.new(beacon_params)
    
    if @beacon.save
      redirect_to @beacon, notice: "Beacon was successfully provisioned. Token: #{@beacon.token}"
    else
      @languages = Language.order(:name)
      @providers = Provider.order(:name)
      @regions = Region.order(:name)
      @tags = Tag.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @languages = Language.order(:name)
    @providers = Provider.order(:name)
    @regions = Region.order(:name)
    @tags = Tag.order(:name)
  end

  def update
    if @beacon.update(beacon_params)
      redirect_to @beacon, notice: "Beacon was successfully updated."
    else
      @languages = Language.order(:name)
      @providers = Provider.order(:name)
      @regions = Region.order(:name)
      @tags = Tag.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_beacon
    @beacon = Beacon.find(params[:id])
  end

  def beacon_params
    params.require(:beacon).permit(:name, :location, :version, :language_id, :provider_id, :region_id, tag_ids: [])
  end

  def redirect_contributors
    redirect_to root_path, alert: "You don't have permission to access this page." unless Current.user&.is_admin?
  end
end
