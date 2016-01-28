require "spec_helper"

describe ApartmentRequestsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/apartment_requests")).to route_to("apartment_requests#index")
    end

    it "routes to #new" do
      expect(get("/apartment_requests/new")).to route_to("apartment_requests#new")
    end

    it "routes to #show" do
      expect(get("/apartment_requests/1")).to route_to("apartment_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/apartment_requests/1/edit")).to route_to("apartment_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/apartment_requests")).to route_to("apartment_requests#create")
    end

    it "routes to #update" do
      expect(put("/apartment_requests/1")).to route_to("apartment_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/apartment_requests/1")).to route_to("apartment_requests#destroy", :id => "1")
    end

  end
end
