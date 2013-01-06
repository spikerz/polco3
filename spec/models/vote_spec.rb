require 'spec_helper'

describe Vote do
  it "should record the number of votes for a bill on each vote" do
    usrs = FactoryGirl.create_list(:random_user, 3, {district: FactoryGirl.create(:district), state: FactoryGirl.create(:oh)})
    r = FactoryGirl.create(:roll)
    r.vote_on(usrs[0], :aye)
    r.vote_on(usrs[1], :nay)
    r.vote_on(usrs[2], :aye)
    Vote.all.size.should eq(3)
    r.vote_count.should eq(3)
  end

  it "should present the description and category for a roll" do
    pending "until we can focus on roll categories"
    roll = FactoryGirl.create(:roll)
    roll.category_description.should eql("")
    roll.category_label.should eql("")
  end

  context "when a user votes on a roll" do
    def set_stage
      @u = FactoryGirl.create(:user)
      l = FactoryGirl.create(:legislator)
      lv = FactoryGirl.create(:legislator_vote)
      @u.representative = l
      @roll = FactoryGirl.create(:roll) # and bill and sponsor
      @roll.vote_on(@u, :aye) # not in district
      @v = @u.votes.first
      lv.roll = @roll
      lv.legislator = l
      lv.save!
    end

    it "should find the tally for a district when a user from that district votes on a roll" do
    #  district = self.user.district.find_vote_on_(self.roll)
      set_stage
      # testing vote.district_tally
      @v.district_tally.should == "<span class=\"green\">1</span>, <span class=\"orange\">0</span>, <span class=\"red\">0"
    end

    it "should find a reps vote on a bill after a user has voted on a roll" do
      # testing vote.reps_vote
      set_stage
      @v.reps_vote.should eql("aye")
    end
  end


end