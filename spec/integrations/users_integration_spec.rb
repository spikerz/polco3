require 'spec_helper'

describe "Users" do
  it "should be able to get a district from a lat, lon" do
    coords=[38.7909,-77.0947]
    User.get_district_from_coords(coords).should eql("VA08")
  end

  it "should be able to get districts from a zip code (multiple)" do
    zip = 45420
    districts = User.get_districts_by_zipcode(zip)
    districts.size.should eql(3)
    districts.first.should eql("OH03")
    districts.last.should eql("OH08")
  end
end
