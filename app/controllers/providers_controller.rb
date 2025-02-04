class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[ show edit update destroy ]

  # GET /providers
  def index
    @providers = Provider.all
  end

  # GET /providers/1
  def show
  end

  # GET /providers/new
  def new
    @provider = Provider.new
  end

  # GET /providers/1/edit
  def edit
  end

  # POST /providers
  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to @provider, notice: "Provider was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /providers/1
  def update
    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to @provider, notice: "Provider was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /providers/1
  def destroy
    @provider.destroy!

    respond_to do |format|
      format.html { redirect_to providers_path, status: :see_other, notice: "Provider was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider
      @provider = Provider.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def provider_params
      params.expect(provider: [ :name, :provider_type, region_ids: [] ])
    end
end
