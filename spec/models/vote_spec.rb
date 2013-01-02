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
    roll = FactoryGirl.create(:roll)
    roll.category_description.should eql("")
    roll.category_label.should eql("")
  end

end