module SpecDataHelper

  def load_legislators(limit=800)
    Legislator.update_legislators(limit)
  end

  def create_20_and_vote_on_10(user)
    vote = [:aye, :aye, :nay, :aye, :nay, :aye, :nay, :aye, :aye, :nay]
    FactoryGirl.create_list(:roll, 20)[0..9].each_with_index do |roll, index|
      roll.vote_on(user, vote[index])
    end
  end

end