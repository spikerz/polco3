require 'spec_helper'

describe User do
  before {
    FactoryGirl.create(:common)
  }
  # A user belongs to a State and a District

  # A user can only join one state and district

  # A user can join a custom group (thinking about implementation)

  # A user can follow many states and districts

  # A user can only join or follow a group once

  # A user should not be able to remove their baseline groups (on the site .. .)

  context "should tell if they have joined or followed a group" do
    before {
      @u = FactoryGirl.create(:user)
      @a = FactoryGirl.create(:polco_group, name: "groupA")
      @b = FactoryGirl.create(:polco_group, name: "groupB")
      @c = FactoryGirl.create(:polco_group, name: "groupC")
      @a.add_member(@u)
      @b.add_follower(@u)
      @a.add_follower(@u)
    }
    it "should show a user has followed" do
      @u.has_followed(@b).should eq(true)
    end
    it "should show c has not followed" do
      @u.has_followed(@c).should eq(false)
    end
    it "should show u has joined a" do
      @u.has_joined(@a).should eq(true)
    end
    it "should show u has not joined b" do
      @u.has_joined(@b).should eq(false)
    end
  end

  context "when it has senators" do
    before {
    u = FactoryGirl.create(:user)
    u.senators << FactoryGirl.create_list(:senator, 2, name_no_details: 'Ralf')
    u.save!
    }
    it "should have exactly two" do
      User.first.senators.size.should eq(2)
    end
    it "should be able to display their names" do
      User.first.senators_names.should eq("Ralf & Ralf")
    end
    it "should join any group they create" do
      u = User.first
      u.custom_groups
    end
  end

  it "should be able to get a list of rolls voted on" do
    u = FactoryGirl.create(:user)
    house_rolls = FactoryGirl.create_list(:house_roll, 10)
    senate_rolls = FactoryGirl.create_list(:senate_roll, 10)
    (house_rolls + senate_rolls).each do |r|
      r.vote_on(u, VOTE_VALUES[rand(0..3)])
    end
    u.rolls_voted_on(:house).size.should eq(10)
    u.rolls_voted_on(:senate).size.should eq(10)
  end

  # can a user follow a group they also join? so far, yes
  context "when you follow groups" do
    before {
      @g = FactoryGirl.create(:polco_group)
      @u = User.create(name: 'tim', email: Faker::Internet.email, district: FactoryGirl.create(:district), state: FactoryGirl.create(:oh))
    }
    it "should be valid" do
      @u.should be_valid
    end
    it "should have only unique groups" do
      @u.custom_groups << @g
      @u.custom_groups << @g
      @u.custom_groups << @g
      @u.custom_groups.size.should eq(1)
    end
  end


  it "should be able to join groups others have already joined" do
    # test to ensure there are no validation problems
    u1, u2 = FactoryGirl.create_list(:random_user, 2)
    g = FactoryGirl.create(:custom_group)
    u1.custom_groups << g
    u1.save!
    u2.custom_groups << g
    u2.valid?.should be true
    u2.save.should be true
  end

end
