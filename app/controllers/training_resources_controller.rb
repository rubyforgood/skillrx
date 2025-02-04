class TrainingResourcesController < ApplicationController
  before_action :set_training_resource, only: %i[ show edit update destroy ]

  # GET /training_resources or /training_resources.json
  def index
    @training_resources = TrainingResource.all
  end

  # GET /training_resources/1 or /training_resources/1.json
  def show
  end

  # GET /training_resources/new
  def new
    @training_resource = TrainingResource.new
  end

  # GET /training_resources/1/edit
  def edit
  end

  # POST /training_resources or /training_resources.json
  def create
    @training_resource = TrainingResource.new(training_resource_params)

    respond_to do |format|
      if @training_resource.save
        format.html { redirect_to @training_resource, notice: "Training resource was successfully created." }
        format.json { render :show, status: :created, location: @training_resource }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_resources/1 or /training_resources/1.json
  def update
    respond_to do |format|
      if @training_resource.update(training_resource_params)
        format.html { redirect_to @training_resource, notice: "Training resource was successfully updated." }
        format.json { render :show, status: :ok, location: @training_resource }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_resources/1 or /training_resources/1.json
  def destroy
    @training_resource.destroy!

    respond_to do |format|
      format.html { redirect_to training_resources_path, status: :see_other, notice: "Training resource was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_resource
      @training_resource = TrainingResource.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def training_resource_params
      params.expect(training_resource: [ :state ])
    end
end
