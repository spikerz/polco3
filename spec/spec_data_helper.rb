module SpecDataHelper

  #def cleanup_database
  #  begin
  #    User.unscoped.delete_all
  #    Bill.unscoped.delete_all
  #    Legislator.unscoped.delete_all
  #  rescue => e
  #    puts "*** ERROR CLEANING UP DATABASE -- #{e.inspect}"
  #  end
  #end

  def log_in_as(name,email)
    visit "/users/sign_in"
    fill_in("name", :with => name)
    fill_in("email", :with => email)
    click_button('')
  end

  def load_legislators
    Legislator.update_legislators
  end

  def create_20_and_vote_on_10(user)
    vote = [:aye, :aye, :nay, :aye, :nay, :aye, :nay, :aye, :aye, :nay]
    FactoryGirl.create_list(:roll, 20)[0..9].each_with_index do |roll, index|
      roll.vote_on(user, vote[index])
    end
  end

end