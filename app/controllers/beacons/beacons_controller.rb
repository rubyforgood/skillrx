module Beacons
  class BeaconsController < BaseController
    before_action :set_beacon, only: %i[show edit update regenerate_key revoke_key]
    before_action :prepare_associations, only: %i[new edit]

    def index
      @beacons = Beacon.includes(:language, :region, :providers, :topics).order(created_at: :desc)
    end

    def new
      @beacon = Beacon.new
    end

    def create
      success, @beacon, api_key = Beacons::Creator.new.call(beacon_params)

      if success
        flash[:notice] = "Beacon was successfully provisioned. API Key: #{api_key}"
        redirect_to @beacon
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
  end
end
