class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[ show edit update destroy ]
  before_action :redirect_contributors

  def index
    @providers = Provider.includes(:regions).order(:name)
  end

  def show
  end

  def new
    @provider = Provider.new
  end

  def edit
  end

  def create
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to @provider, notice: "Provider was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to @provider, notice: "Provider was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @provider.destroy
        format.html { redirect_to providers_path, status: :see_other, notice: "Provider was successfully destroyed." }
      else
        format.html { redirect_to providers_path, status: :see_other, alert: @provider.errors.full_messages.to_sentence }
      end
    end
  end

  private
    def set_provider
      @provider = Provider.find(params.expect(:id))
    end

    def provider_params
      params.expect(provider: [ :name, :provider_type, :file_name_prefix, region_ids: [] ])
    end
end
