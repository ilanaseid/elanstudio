require "spec_helper"

describe ApartmentVisitsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/apartment_visits")).to route_to("apartment_visits#index")
    end

    it "routes to #new" do
      expect(get("/apartment_visits/new")).to route_to("apartment_visits#new")
    end

    it "routes to #show" do
      expect(get("/apartment_visits/1")).to route_to("apartment_visits#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/apartment_visits/1/edit")).to route_to("apartment_visits#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/apartment_visits")).to route_to("apartment_visits#create")
    end

    it "routes to #update" do
      expect(put("/apartment_visits/1")).to route_to("apartment_visits#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/apartment_visits/1")).to route_to("apartment_visits#destroy", :id => "1")
    end

  end
end
