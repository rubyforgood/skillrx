class RegionsController < ApplicationController
  before_action :redirect_contributors
  before_action :set_region, only: %i[ show edit update destroy ]

  # GET /regions
  def index
    @regions = Region
      .left_joins(:providers)
      .select("regions.*, COUNT(providers.id) AS providers_count")
      .group("regions.id")
      .order(:name)
  end

  # GET /regions/1
  def show
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1/edit
  def edit
  end

  # POST /regions
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to @region, notice: "Region was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /regions/1
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to @region, notice: "Region was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  # DELETE /regions/1
  def destroy
    @region.destroy!

    respond_to do |format|
      format.html { redirect_to regions_path, status: :see_other, notice: "Region was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def region_params
      params.expect(region: [ :name ])
    end
end
