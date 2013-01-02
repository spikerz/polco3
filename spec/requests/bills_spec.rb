require 'spec_helper'

describe "Bills" do
  context "can work with external data" do

    before :each do
      Legislator.update_legislators
    end

    it "should be able to pull in a bill and update it" do
      bill_name = "h3605"
      b = Bill.find_or_create_by(:title => bill_name, :govtrack_name => bill_name)
      b.update_bill # here HTTParty.get needs stubbed again (WebMock ? or VCR?)
      b.titles[0].last.should eql("Global Online Freedom Act of 2011")
      b.should be_valid
    end

    it "should correctly load a bills co-sponsors" do
      pending "until we can get their co-sponsors figured out"
    end

  end
end
