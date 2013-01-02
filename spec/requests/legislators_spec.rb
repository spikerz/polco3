require 'spec_helper'

describe "Legislators" do

  it "should be able to import a legislator" do
    john = GovTrack::Person.find_by_firstname_and_lastname('John','McCain')
    Legislator.save_legislator(john)
    l = Legislator.first
    l.name.should eql(john.name)
    l.gender_label.should eql('male')
    l.current_role.role_type_label.should eq('Senator')
    l.roles.size.should eql(7)
  end

  it "should not duplicate an existing legislator" do
    john = GovTrack::Person.find_by_firstname_and_lastname('John','McCain')
    Legislator.save_legislator(john)
    Legislator.save_legislator(john)
    Legislator.all.size.should eql(1)
  end

  it "should be able to read in all legislators" do
    Legislator.update_legislators
    # should be at least the number of reps (435) + the number of senators
    Legislator.all.size.should be >= (535)
  end
end
