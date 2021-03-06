require 'spec_helper'

describe Bill do

  context "when I interface with legislators a Bill" do

    it "should be able to add a sponsor to a bill" do
      b = Bill.new
      b.title = Faker::Company.name
      b.govtrack_name = "s182" #fake
      sponsor = FactoryGirl.create(:legislator, govtrack_id: 400032, firstname: 'Chad', lastname: 'Whiddle', nickname: 'Tracey')
      b.sponsor = sponsor
      b.sponsor.full_name.should eq("Tracey Whiddle")
      # the the legislator should be sponsoring this bill
      sponsor.bills.first.should eq(b)
    end

    it "should be able to describe it's status" do
      b = FactoryGirl.create(:bill, current_status: "fail_second_senate")
      b.current_status_explanation.should eq("Passed House, Failed Senate on 2011-01-05")
    end

    it "should show if it has passed" do
      b = FactoryGirl.create(:bill, current_status: 'passed_simpleres')
      b.passed?.should eq(true)
      b_failed = FactoryGirl.create(:bill, current_status: 'fail_originating_house')
      b_failed.passed?.should eq(false)
    end

    it "should have title" do
      FactoryGirl.create(:bill).title.should eql("H.Res. 1: Electing officers of the House of Representatives.")
    end

    #it "should be able to get a list of subjects for a bill" do
    #  #b = FactoryGirl.create(:bill)
    #  load_legislators(10)
    #  b = Bill.find_or_create_by(:title => "h3605", :govtrack_name => "h3605")
    #  b.subjects.size.should eql(15)
    #  b.subjects.last.name.should eql("Trade restrictions")
    #end

    it "should have cosponsors" do
      pending "until we get co-sponsors figured out"
      b = Bill.new(
           :congress => 112,
           :bill_type => 's',
           :bill_number => 368,
           :title => 's368',
           :govtrack_name => 's368'
      )
      cosponsor_ids = ["412411", "400626", "400224"]
      cosponsor_ids.each do |id|
         FactoryGirl.create(:legislator, govtrack_id: id)
      end
      b.save_cosponsors(cosponsor_ids)
      b.cosponsors.to_a.count.should eq(3)
    end

    #it "should be able to get latest action" do
    #  b = FactoryGirl.create(:bill)
    #  b.get_latest_action.should eql({:date => "2011-02-17", :description => "Message on Senate action sent to the House."})
    #end

    #it "should show the latest status for a bill" do
    #  b = FactoryGirl.create(:bill)
    #  b.bill_actions = [['2011-08-14', 'augustine'], ['2011-05-12', 'Cyril'], ['2001-09-15', 'Pelagius']]
    #  b.bill_state = 'REFERRED'
    #  b.get_latest_action[:description].should eq("augustine")
    #  b.bill_state.should eq('REFERRED')
    #end

  end

end
