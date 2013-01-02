require 'spec_helper'

describe "Bills" do
  context "can work with external data" do

    #before :each do
    #  Legislator.update_legislators
    #end

    it "should be able to pull in a bill and update it" do
      gtb = GovTrack::Bill.find_by_id(69293)
      FactoryGirl.create(:legislator, govtrack_id: gtb.sponsor.id)
      b = Bill.from_govtrack(gtb)
      b.should be_valid
      b.title.should eql(gtb.title)
    end

    it "should fail gracefully if the sponsor does not exist" do
      gtb = GovTrack::Bill.find_by_id(69293)
      expect {Bill.from_govtrack(gtb)}.to raise_error(RuntimeError, /sponsor not found/)
    end

    it "should save cosponsors" do
      pending "until we get cosponsors set up"
    end

    it "should pull in the latest bills" do
      pending
    end

    it "should tell how members are voting on a bill" do
      v = GovTrack::Vote.find_by_id(1)
      FactoryGirl.create(:bill, govtrack_id: 75622)
      gtb = v.related_bill
      FactoryGirl.create(:legislator, govtrack_id: gtb.sponsor.id)
      bill = Bill.from_govtrack(gtb)
      roll = bill.rolls.first
      roll.legislator_votes
    end

    it "should save rolls and reveal legislator votes" do
      v = GovTrack::Vote.find_by_id(1)
      FactoryGirl.create(:bill, govtrack_id: 75622)
      gtb = v.related_bill
      FactoryGirl.create(:legislator, govtrack_id: gtb.sponsor.id)
      b = Bill.from_govtrack(gtb)
      b.should be_valid
      b.rolls.size.should be >= 1
      b.rolls.first.legislator_votes.size.should be > 100
    end

  end
end
