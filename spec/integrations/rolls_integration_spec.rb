require 'spec_helper'

describe "Rolls" do
  it "should be able to add all legislator_votes for a given roll (vote)" do
    roll = Roll.from_govtrack GovTrack::Vote.find_by_id(1)
    roll.add_votes
    roll.legislator_votes.size.should be > 100
  end

  it "should be able to pull in rolls" do
    Roll.pull_in_votes(1, 2)
    Roll.all.size.should eql(1)
    r = Roll.first
    LegislatorVote.all.size.should eql(2)
    r.legislator_votes.size.should be > 0
  end
end
