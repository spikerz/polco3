require 'spec_helper'

describe "Vote on rolls" do
  #background do
  #  User.make(:email => 'user@example.com', :password => 'caplin')
  #end

  it "Voting on house bills" do
    load_bills("house", count = 10)
    visit '/represent/house_bills'
    # need to login
    page.should have_content 'Nick, Tom, and Tim:'
  end

  #given(:other_user) { User.make(:email => 'other@example.com', :password => 'rous') }

end