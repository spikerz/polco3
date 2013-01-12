require 'spec_helper'

describe Legislator do

  before :each do
    @l = FactoryGirl.create(:legislator)
  end

  it "should have a party" do
    @l.party.should eql("Democrat")
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

  #it "should show senators votes on a bill" do
  #  r = FactoryGirl.create(:roll)
  #  s1 = FactoryGirl.create(:legislator, firstname: "chad")
  #  s2 = FactoryGirl.create(:legislator, firstname: "ryan")
  #  u = FactoryGirl.create(:user)
  #  LegislatorVote.create(legislator_id: s1.id, value: :aye, roll_id: r.id)
  #  LegislatorVote.create(legislator_id: s2.id, value: :nay, roll_id: r.id)
  #  u.senators << [s1, s2]
  #  u.save
  #  u.reload
  #  u.senators_vote_on(r).should eq([{:name=>"chad Ackerman", :value=>"aye"}, {:name=>"ryan Ackerman", :value=>"nay"}])
  #end

end
