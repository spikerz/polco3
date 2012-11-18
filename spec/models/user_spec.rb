require 'spec_helper'

describe User do

  # A user belongs to a State and a District

  # A user can only join one state and district

  # A user can join a custom group (thinking about implementation)

  # A user can follow many states and districts

  # A user can only join or follow a group once

  # A user should not be able to remove their baseline groups (on the site .. .)

  it "should be able to get a list of rolls voted on" do
    u = FactoryGirl.create(:user)
    house_rolls = FactoryGirl.create_list(:house_roll,10)
    senate_rolls = FactoryGirl.create_list(:senate_roll,10)
    (house_rolls + senate_rolls).each do |r|
      r.vote_on(u,VOTE_VALUES[rand(0..3)])
    end
    u.rolls_voted_on(:house).size.should eq(10)
    u.rolls_voted_on(:senate).size.should eq(10)
  end

  # can a user follow a group they also join? so far, yes

  it "should only be able to follow a group once" do
    g = FactoryGirl.create(:polco_group)
    u = User.create(name: 'tim', email: Faker::Internet.email, district: FactoryGirl.create(:district), state: FactoryGirl.create(:oh))
    u.common_groups << FactoryGirl.create(:common)
    u.custom_group_ids << g.id
    u.should be_valid
    u.custom_group_ids << g.id
    u.custom_group_ids << g.id
    u.custom_group_ids << g.id
    u.custom_group_ids.size.should eq(4)
    u.save
    u.custom_groups.size.should eq(1)
  end

  it "should be able to join groups others have already joined" do
    # test to ensure there are no validation problems
    u1, u2 = FactoryGirl.create_list(:random_user,2)
    g = FactoryGirl.create(:custom_group)
    u1.custom_groups << g
    u1.save!
    u2.custom_groups << g
    u2.valid?.should be true
    u2.save.should be true
  end

  #it "should be able to show all bills by chamber a user has not voted on" do
  #  u = FactoryGirl.create(:user)
  #  create_20_and_vote_on_10(u)
  #  (u.bills_voted_on(:house).size + u.bills_voted_on(:senate).size).should eq(10)
  #  (u.rolls_not_voted_on(:house).size + u.rolls_not_voted_on(:senate).size).should eq(10)
  #  (u.bills_voted_on(:house)+u.bills_voted_on(:senate)).should include(Bill.first)
  #  not_voted_on_rolls = Bill.all.to_a - Vote.all.map{|v| v.bill}
  #  (u.rolls_not_voted_on(:house)+u.rolls_not_voted_on(:senate)).map(&:id).should include(not_voted_on_rolls.first.id)
  #end

end
