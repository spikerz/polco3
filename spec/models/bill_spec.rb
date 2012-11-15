require 'spec_helper'

describe Bill do

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

  end

  context "when I interface with legislators a Bill" do

    it "should be able to show both senators votes if the bill is a sr" do
      pending "until i get legislators set up"
      #senator_votes = @user1.senators_vote_on(@senate_bill_with_roll_count)
      #assert_equal :nay, senator_votes.first[:vote], "senator's vote does not match"
    end

    it "should be able to add a sponsor to a bill" do
      b = Bill.new
      b.title = Faker::Company.name
      b.govtrack_name = "s182" #fake
      s = FactoryGirl.create(:legislator, govtrack_id: 400032, first_name: 'Chad', last_name: 'Whiddle')
      b.save_sponsor(400032)
      b.sponsor.full_name.should eq("Chad Whiddle")
      # the the legislator should be sponsoring this bill
      s.bills.first.should eq(b)
    end

    it "should be able to get latest action" do
      b = FactoryGirl.create(:bill)
      b.get_latest_action.should eql({:date => "2011-02-17", :description => "Message on Senate action sent to the House."})
    end

    it "should show the latest status for a bill" do
      b = FactoryGirl.create(:bill)
      b.bill_actions = [['2011-08-14', 'augustine'], ['2011-05-12', 'Cyril'], ['2001-09-15', 'Pelagius']]
      b.bill_state = 'REFERRED'
      b.get_latest_action[:description].should eq("augustine")
      b.bill_state.should eq('REFERRED')
    end

    it "should be able to describe it's status" do
      b = FactoryGirl.create(:bill, bill_state: "VETOED:OVERRIDE_FAIL_SECOND:SENATE")
      b.status_description.should eq("Veto override passed in the House (the originating chamber) but failed in the Senate.")
    end

    it "should show if it has passed" do
      b = FactoryGirl.create(:bill, bill_state: 'ENACTED:SIGNED')
      b.passed?.should eq(true)
      b_failed = FactoryGirl.create(:bill, bill_state: 'PROV_KILL:CLOTUREFAILED')
      b_failed.passed?.should eq(false)
    end

    it "should have a long and a short title" do
      b = FactoryGirl.create(:bill)
      titles = b.titles
      titles.should_not be_nil
      b.long_title.should eql("This is the official title.")
      b.short_title.should eql("This is the short title")
    end

    it "should be able to get a list of subjects for a bill" do
      #b = FactoryGirl.create(:bill)
      load_legislators
      b = Bill.find_or_create_by(:title => "h3605", :govtrack_name => "h3605")
      b.update_bill # should modify this to work offline vcr ? with HTTParty.get govtrack
      b.subjects.size.should eql(15)
      b.subjects.last.name.should eql("Trade restrictions")
    end

    it "should have cosponsors" do
     b = Bill.new(
         :congress => 112,
         :bill_type => 's',
         :bill_number => 368,
         :title => 's368',
         :govtrack_name => 's368'
     )
     cosponsor_ids = ["412411", "400626", "400224", "412284", "400570", "400206", "400209", "400068", "400288", "412271", "412218", "400141", "412480", "412469", "400277", "400367", "412397", "412309", "400411", "412283", "412434", "400342", "400010", "400057", "400260", "412487", "412436", "400348", "412478", "400633", "400656", "400115"]
     cosponsor_ids.each do |id|
       FactoryGirl.create(:legislator, govtrack_id: id)
     end
     b.save_cosponsors(cosponsor_ids)
     b.cosponsors.to_a.count.should eq(32)
    end

  end


end
