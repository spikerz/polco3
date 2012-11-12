require "spec_helper"

describe PolcoGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/polco_groups").should route_to("polco_groups#index")
    end

    it "routes to #new" do
      get("/polco_groups/new").should route_to("polco_groups#new")
    end

    it "routes to #show" do
      get("/polco_groups/1").should route_to("polco_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/polco_groups/1/edit").should route_to("polco_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/polco_groups").should route_to("polco_groups#create")
    end

    it "routes to #update" do
      put("/polco_groups/1").should route_to("polco_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/polco_groups/1").should route_to("polco_groups#destroy", :id => "1")
    end

  end
end
