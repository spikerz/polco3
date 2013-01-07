require 'spec_helper'

describe PolcoGroup do
  before :each do
    # need state and district
    @oh = FactoryGirl.create(:oh)
    @d = FactoryGirl.create(:district)
    cg = FactoryGirl.create(:common)
    usrs = FactoryGirl.create_list(:random_user, 3, {state: @oh, district: @d})
    grps = FactoryGirl.create_list(:polco_group, 5)
    usrs.each do |u|
      u.common_groups << cg
    end
    usrs[0].joined_groups << [grps[0..2]]
    usrs[1].joined_groups << [grps[3..4]]
    usrs[2].joined_groups << [grps[2..3]]
    # user 0 => 0,1,2
    # user 1 => 3,4
    # user 2 => 2,3
    usrs[1].followed_groups << grps[1]
    # means that 2=>0,2, 3=> 1,2 and 4,0,1=> one
    @usrs = usrs
    @grps = grps
  end

  # Determine the atomic element  .. . roll

  # Every user is in the common polco group -- why don't we track this at the roll
  it "should record all votes in a common group" do
    # this common group can't be removed so we make it a property of the roll
    pending "until we test this"
  end

  it "should have a rep if it is a district" do
    @d.the_rep.should eq("Vacant")
  end

  it "should have constituents for a district" do
    #has_many :constituents, class_name: "User", inverse_of: :district
    @d.constituents.size.should eq(3)
  end

  it "should have state constituents" do
    @oh.state_constituents.size.should eq(3)
  end

  it "should show the vote count in each group" do
    r = FactoryGirl.create(:roll)
    r.vote_on(@usrs[0], :aye)
    r.vote_on(@usrs[1], :nay)
    r.vote_on(@usrs[2], :aye)
    # they get vote count from joined groups (0 and 2 are in 2)
    @grps[2].vote_count.should eq(2)
    PolcoGroup.where(type: :common).first.votes.size.should eq(3)
  end

  it "should be able to show the rep for a district (and fail gracefully if it doesn't exist)" do
    d = FactoryGirl.create(:polco_group, name: nil, type: :district)
    d.the_rep.should eql("Only districts can have a representative")
  end

  it "should be able to find the rep for a district" do
    data = @d.name.match(/([A-Z]+)(\d+)/)
    state, district_num = data[1], data[2].to_i
    l = FactoryGirl.create(:legislator, chamber: :house, state: state, district: district_num)
    @d.the_rep.should eql(l)
  end

  it "should be able to display a list of representatives" do
    FactoryGirl.create(:legislator, chamber: :house, firstname: 'mike', lastname: 'handy')
    FactoryGirl.create(:legislator, chamber: :house, firstname: 'brian', lastname: 'larson')
    Legislator.representatives.size.should eql(2)
  end

  it "should be able to find the senators for a state" do
    va = FactoryGirl.create(:polco_group, type: :state, name: 'VA')
    junior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'apollo', state: 'VA')
    senior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'daphne', state: 'VA')
    junior.current_role.startdate = Date.parse("August 12, 2000")
    senior.current_role.enddate = Date.parse("August 12, 1976")
    senators = va.senators_hash
    senators[:junior_senator].twitterid = "apollo"
    senators[:senior_senator].twitterid = "daphne"
  end

  it "produces nil when there are not two senators" do
    va = FactoryGirl.create(:polco_group, type: :state, name: 'VA')
    ky = FactoryGirl.create(:polco_group, type: :state, name: 'KY')
    junior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'apollo', state: 'VA')
    senior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'daphne', state: 'VA')
    # just one from ohio
    junior_oh = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'cupid', state: 'OH')
    junior.current_role.startdate = Date.parse("August 12, 2000")
    senior.current_role.enddate = Date.parse("August 12, 1976")
    junior_oh.current_role.startdate = Date.parse("August 12, 1827")
    va.senators_hash.size.should be 2
    @oh.senators_hash.nil?.should be true
    ky.senators_hash.nil?.should eql(true)
  end

  it "should build an array of states with senators" do
    FactoryGirl.create(:polco_group, type: :state, name: 'VA')
    junior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'apollo', state: 'VA')
    senior = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'daphne', state: 'VA')
    # just one from ohio
    junior_oh = FactoryGirl.create(:legislator, chamber: :senate, twitterid: 'cupid', state: 'OH')
    junior.current_role.startdate = Date.parse("August 12, 2000")
    senior.current_role.enddate = Date.parse("August 12, 1976")
    junior_oh.current_role.startdate = Date.parse("August 12, 1827")
    states_with_senators = PolcoGroup.states_with_senators
    states_with_senators.size.should be 1
    state = states_with_senators.first
    state[:state].name.should eql('VA')
    state[:senior_senator].twitterid.should eql('apollo')
    state[:junior_senator].twitterid.should eql('daphne')
  end

  it "should have an owner" do
    pg = PolcoGroup.new
    pg.owner = @usrs[0]
    pg.save!
    pg.owner.should eql(@usrs[0])
  end

  it "should assign the owner when one creates a custom group" do
    pg = PolcoGroup.new
    # create a custom group
    # it should have a user
  end

  context "can have followers and members and " do
    # What is the difference between joined and followed groups?
    # If a user has joined a group they can vote with that group,
    # otherwise they only watch that group on their stats pages.
    it "should be able to count them" do
      #has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :custom_groups # uniq: true
      #has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups #, uniq: true
      @grps[3].members.size.should eq(2)
      @grps[0].members.size.should eq(1)
      @grps[3].followers.size.should eq(0)
    end

    it "should have a member, vote and follower count" do
      r = FactoryGirl.create(:roll)
      r.vote_on(@usrs[0], :aye)
      r.vote_on(@usrs[1], :nay)
      r.vote_on(@usrs[2], :aye)
      # means that 2=>0,2, 3=> 1,2 and 4,0,1=> one
      @grps[2].update_counters
      @grps[2].member_count.should eql(2)
      @grps[2].vote_count.should eql(2)
      @grps[2].follower_count.should eql(0)
      @grps[1].update_counters
      @grps[1].member_count.should eql(1)
      @grps[1].vote_count.should eql(1)
      @grps[1].follower_count.should eql(1)
    end

  end

  context "can be joined, then it " do

  end

  context "can be followed, then it" do

  end

end