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

    #it "should fail gracefully if the sponsor does not exist" do
    #  gtb = GovTrack::Bill.find_by_id(69293)
    #  expect {Bill.from_govtrack(gtb)}.to raise_error(RuntimeError, /sponsor not found/)
    #end

    it "should save cosponsors" do
      pending "until we get cosponsors set up"
    end

    it "should pull in the latest bills" do
      pending
    end

    context "when members are voting" do
      before {
        v = GovTrack::Vote.find_by_id(1)
        #FactoryGirl.create(:bill, govtrack_id: 75622)
        gtb = v.related_bill
        #FactoryGirl.create(:legislator, govtrack_id: gtb.sponsor.id)
        @b = Bill.from_govtrack(gtb, true, 10)
      }

      it "should be valid" do
        @b.should be_valid
      end

      it "should have multiple rolls " do
        @b.rolls.size.should be 7
      end

      it "should have a 10 legislator votes" do
        @b.rolls.first.legislator_votes.size.should be 10
      end
    end

    it "should be able to pull in two bills (with no legislators added)" do
      Bill.pull_in_bills(112,2)
      Bill.all.size.should eql(2)
    end

  end
end
