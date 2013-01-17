require 'spec_helper'

describe "Users" do
  it "should be able to get a district from a lat, lon" do
    result = User.get_district_from_coords([38.7909,-77.0947])
    result[:district].should eql("VA08")
  end

  it "should be able to get districts from a zip code (multiple)" do
    pending "until we reinstate the zip code feature"
    zip = 45420
    districts = User.get_districts_by_zipcode(zip)
    districts.size.should eql(3)
    districts.first[:district].should eql("OH03")
    districts.last[:district].should eql("OH08")
  end

  it "should be able to find the appropriate role" do
    User.find_role("Junior Seat").should eql(:junior_senator)
  end

  it "should be able to get all members from coords" do
    members = User.get_members_from_([38.7909,-77.0947])
    members[:senior_senator].govtrack_id.should eql(412321)
    members[:junior_senator].govtrack_id.should eql(412321)
    members[:representative].govtrack_id.should eql(400283)
  end
end
