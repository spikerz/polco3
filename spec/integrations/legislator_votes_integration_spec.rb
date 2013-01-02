require 'spec_helper'

describe "LegislatorVotes" do
  it "should be able to create itself from a govtrack object" do
    vv = GovTrack::VoteVoter.find(_id: 29612823).first
    FactoryGirl.create(:legislator, govtrack_id: vv.person.id)
    FactoryGirl.create(:roll, govtrack_id: vv.vote.id)
    lv = LegislatorVote.from_govtrack(vv)
    lv.vote_description.should eql(vv.vote_description)
  end
end
