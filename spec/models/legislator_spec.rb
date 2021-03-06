require 'spec_helper'

describe Legislator do

  before :each do
    @l = FactoryGirl.create(:legislator)
  end

  it "should have a party" do
    @l.party.should eql("Democrat")
  end

  it "should match the district for legislator" do
    FactoryGirl.create(:district, name: "NY05")
    FactoryGirl.create(:district) # VA08, just for confusion
    Legislator.assign_districts
    Legislator.first.legislator_district.name.should == "NY05"
    PolcoGroup.where(name: "NY05").first.rep.name.should == @l.name
  end

  it "should correctly handle a legislator from a state with only one district" do
    FactoryGirl.create(:district, name: "AK-AL")
    l = FactoryGirl.create(:legislator, chamber: :house, district: "0", state: "AK", name: "foo")
    l.district_name.should eq('AK-AL')
    Legislator.assign_districts
    Legislator.where(name: "foo").first.legislator_district.name.should eq("AK-AL")
  end

  it "when a representative should have a district" do
    @l.legislator_district = FactoryGirl.create(:district)
    @l.save
    Legislator.first.legislator_district.name.should eq("VA08")
  end

  it "should have a chamber" do
    @l.chamber_label.should eql("U.S. House of Representatives")
  end

  it " should show how they voted on a bill" do
    b = FactoryGirl.create(:bill)
    LegislatorVote.create(legislator_id: @l.id, bill_id: b.id, value: :aye)
    @l.vote_on(b).should eq :aye
  end

  it "We should be able to read their full state name" do
    @l.state_name.should eq("New York")
  end

  it "should have a gender" do
    @l.gender_label.should eq('male')
  end

  it "should be able to add constituents for state and district" do
    FactoryGirl.create(:common)
    user = FactoryGirl.create(:user)
    @l.state_constituents << user
    @l.district_constituents << user
    @l.state_constituents.count.should eq(1)
    @l.district_constituents.count.should eq(1)
  end

  it "should show senators votes on a bill" do
    FactoryGirl.create(:common)
    r = FactoryGirl.create(:roll)
    s1 = FactoryGirl.create(:legislator, name_no_details: "chad")
    s2 = FactoryGirl.create(:legislator, name_no_details: "ryan")
    u = FactoryGirl.create(:user)
    LegislatorVote.create(legislator_id: s1.id, value: :aye, roll_id: r.id)
    LegislatorVote.create(legislator_id: s2.id, value: :nay, roll_id: r.id)
    u.senators << [s1, s2]
    u.save
    u.reload
    u.senators_vote_on(r).should eq([{:name=>"chad", :value=>:aye}, {:name=>"ryan", :value=>:nay}])
  end

end
