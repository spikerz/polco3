require 'spec_helper'

describe "Rolls" do
  it "should be able to add all legislator_votes for a given roll (vote)" do
    roll = Roll.from_govtrack GovTrack::Vote.find_by_id(1)
    roll.add_votes
    roll.legislator_votes.size.should be > 100
  end
end
