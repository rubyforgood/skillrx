class BeaconsController < ApplicationController
  before_action :redirect_contributors
  before_action :set_beacon, only: %i[show edit update regenerate_key revoke_key]

  def index
    @beacons = Beacon.includes(:language, :region, :providers, :topics).order(created_at: :desc)
  end

  def new
    prepare_associations
  end

  def create
    success, @beacon, api_key = Beacons::Creator.new.call(beacon_params)

    case Beacons::Creator.new.call(beacon_params)
    when [true, @beacon, api_key]
      flash[:notice] = "Beacon was successfully provisioned. API Key: #{api_key}"
      redirect_to @beacon
    when [false, _, _]
      prepare_associations
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    prepare_associations
  end

  def update
    if @beacon.update(beacon_params)
      redirect_to @beacon, notice: "Beacon was successfully updated."
    else
      prepare_associations
      render :edit, status: :unprocessable_entity
    end
  end

  def regenerate_key
    api_key = @beacon.regenerate
    flash[:notice] = "API key has been successfully regenerated. API Key: #{api_key}"
    redirect_to @beacon

    rescue => e
      flash[:alert] = "API key could not be regenerated."
      redirect_to @beacon
  end

  def revoke_key
    api_key = @beacon.revoke!
    flash[:notice] = "API key has been successfully revoked."
    redirect_to @beacon

    rescue => e
      flash[:alert] = "API key could not be revoked."
      redirect_to @beacon
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
  
  def redirect_contributors
    redirect_to root_path, alert: "You don't have permission to access this page." unless Current.user&.is_admin?
  end
end
