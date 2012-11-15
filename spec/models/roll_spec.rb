require 'spec_helper'

describe Roll do

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
    usrs[0].custom_groups << [grps[0..2]]
    usrs[1].custom_groups << [grps[3..4]]
    usrs[2].custom_groups << [grps[2..3]]
    # user 0 => 0,1,2
    # user 1 => 3,4
    # user 2 => 2,3
    # means that 2=>0,2, 3=> 1,2 and 4,0,1=> one
    @usrs = usrs
    @grps = grps
  end


  it "should be able to show the house representatives vote if the roll is a hr" do
    load_legislators
    b = FactoryGirl.create(:bill, bill_type: 'hr', congress: '112', bill_number: '26', govtrack_id: 'hr112-26')
    roll = Roll.bring_in_roll("h2011-9.xml")
    # this corresponds to hr112-26
    u = FactoryGirl.create(:user)
    l = roll.legislator_votes.first.legislator
    u.representative = l
    u.save
    b.reload
    u.reload
    u.reps_vote_on(roll).should eq("aye")
  end

  context "has basic properties and " do

    it "should be able to update the vote count on rolls" do
      @oh = FactoryGirl.create(:oh)
      @d = FactoryGirl.create(:district)
      @oh.vote_count.should eq(0)
      u = FactoryGirl.create(:user, {state: @oh, district: @d})
      b = FactoryGirl.create(:roll)
      b.vote_on(u,:aye)
      @d.reload
      @d.vote_count.should eq(1)
      @oh.reload
      @oh.vote_count.should eq(1)
    end

    it "should increment a roll's count each time we vote" do
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u,:aye)
      b.vote_count.should eq(1)
    end

    it "should tell me the most popular rolls" do
      users = FactoryGirl.create_list(:random_user, 3, state: FactoryGirl.create(:oh), district: FactoryGirl.create(:district))
      rolls = FactoryGirl.create_list(:roll, 12).each do |roll|
        users.each do |user|
          roll.vote_on(user, [:aye, :nay, :abstain, :present][rand(4)]) if rand > 0.2
        end
      end
      most_popular_rolls = Roll.most_popular.to_a
      most_popular_rolls.size.should eq(10)
      most_popular_rolls.first.vote_count.should be >= most_popular_rolls.last.vote_count
    end

  end # basic properties of a roll context

  context "interfaces with users and " do

    it "should let a user vote on the roll" do
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u, :aye)
    end

    it "should tell you how a user voted on a roll" do
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u, :aye)
      b.voted_on?(u).should eql(:aye)
    end

    it "should get the overall users vote on a roll" do
      b = FactoryGirl.create(:roll)
      #pg = FactoryGirl.create(:common)
      state = FactoryGirl.create(:oh)
      district = FactoryGirl.create(:district)
      users = FactoryGirl.create_list(:random_user, 4, {state: state, district: district})
      b.vote_on(users[0], :aye)
      b.vote_on(users[1], :nay)
      b.vote_on(users[2], :aye)
      b.vote_on(users[3], :abstain)
      tally = b.get_overall_users_vote
      tally.should == {:ayes => 2, :nays => 1, :abstains => 1, :presents => 0}
    end

    it "should record the group when a user votes on a roll" do
      Bill.delete_all
      PolcoGroup.delete_all
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u, :aye)
      b.votes.size.should eql(1)
      # b.votes.all.map { |v| puts "#{v.polco_group.name}" }
      groups = b.votes.map{|v| v.polco_groups.map(&:name)}.uniq
      groups.first.should include('VA08')
    end

    it "should show what the current users vote is on a specific roll" do
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u, :aye)
      b.users_vote(u).should eql(:aye)
    end

    it "should show the votes for a specific district that a user belongs to" do
      #PolcoGroup.destroy_all
      Vote.destroy_all
      PolcoGroup.destroy_all
      #pg = FactoryGirl.create(:common)
      cg = FactoryGirl.create(:custom_group)
      b = FactoryGirl.create(:roll)
      dg = FactoryGirl.create(:district)
      user1, user2, user3, user4 = FactoryGirl.create_list(:random_user, 4, {state: FactoryGirl.create(:oh)})
      user1.custom_groups << cg
      user2.custom_groups << cg
      user3.custom_groups << cg
      user4.custom_groups << cg
      user1.district = PolcoGroup.create(name: "test group"); user1.save
      user2.district = dg; user2.save
      user3.district = dg; user3.save
      user4.district = dg; user4.save
      b.vote_on(user1, :aye) # not in district
      b.vote_on(user2, :nay)
      b.vote_on(user3, :abstain)
      b.vote_on(user4, :aye)
      user3.district.get_tally.should eql({:ayes => 1, :nays => 1, :abstains => 1, :presents => 0})
    end

    it "should be able to show votes for a specific state that a user belongs to" do
      #pg = FactoryGirl.create(:common)
      cg = FactoryGirl.create(:custom_group)
      b = FactoryGirl.create(:roll)
      oh = FactoryGirl.create(:oh)
      user1, user2, user3, user4 = FactoryGirl.create_list(:random_user, 4,
                                                           {district: FactoryGirl.create(:district), state: oh})
      user1.state = PolcoGroup.create(type: :state, name: "CA"); user1.save
      user1.custom_groups << cg
      user2.custom_groups << cg
      user3.custom_groups << cg
      user4.custom_groups << cg
      b.vote_on(user1, :aye)
      b.vote_on(user2, :nay)
      b.vote_on(user3, :abstain)
      b.vote_on(user4, :aye)
      user2.reload
      user2.state.get_tally.should eql({:ayes=>1, :nays=>1, :abstains=>1, :presents=>0})
      user1.reload
      user1.state.get_tally.should eql({:ayes => 1, :nays => 0, :abstains => 0, :presents => 0})
    end

    it "should silently block a user from voting twice on a roll" do
      b = FactoryGirl.create(:roll)
      u = FactoryGirl.create(:user)
      b.vote_on(u, :aye)
      b.vote_on(u, :aye)
      puts u.custom_groups.map(&:name)
      b.votes.size.should eql(1)
    end

    it "should reject a value for vote other than :aye, :nay or :abstain" do
      b = FactoryGirl.create(:roll)
      v1 = b.votes.new
      v1.user = FactoryGirl.create(:user)
      #v1.polco_group = FactoryGirl.create(:polco_group)
      v1.value = :happy
      v1.should_not be_valid
      #assert_equal "You can only vote yes, no or abstain", v1.errors.messages[:value].first
    end

  end

  # this about to get big!
  it "should show the votes in each polco group" do
    b = FactoryGirl.create(:roll)
    b.vote_on(@usrs[0], :aye)
    b.vote_on(@usrs[1], :nay)
    b.vote_on(@usrs[2], :aye)
    Vote.all.size.should eq(3)
    b.vote_count.should eq(3)
  end

  # When we vote with a roll (or amendment?),
  # we want to see our vote compared
  # with all of Polco, our District, our State, or - JPTXCT
  # any Custom Groups that others have created
  it "should show how the district and state are voting on a specific roll" do
    r = FactoryGirl.create(:roll)
    r.vote_on(@usrs[0], :aye)
    r.vote_on(@usrs[1], :nay)
    r.vote_on(@usrs[2], :aye)
    @oh.reload
    @d.reload
    @oh.format_votes_tally(r).should eq("2, 1, 0")
    @d.format_votes_tally(r).should eq("2, 1, 0")
  end

end
