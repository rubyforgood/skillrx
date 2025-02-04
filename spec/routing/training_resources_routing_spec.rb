require "rails_helper"

RSpec.describe TrainingResourcesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/training_resources").to route_to("training_resources#index")
    end

    it "routes to #new" do
      expect(get: "/training_resources/new").to route_to("training_resources#new")
    end

    it "routes to #show" do
      expect(get: "/training_resources/1").to route_to("training_resources#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/training_resources/1/edit").to route_to("training_resources#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/training_resources").to route_to("training_resources#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/training_resources/1").to route_to("training_resources#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/training_resources/1").to route_to("training_resources#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/training_resources/1").to route_to("training_resources#destroy", id: "1")
    end
  end
end
