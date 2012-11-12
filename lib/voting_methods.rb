module VotingMethods

  def process_votes(votes)
    # takes a list of votes (of one type) and will add up all the nays, abstains, ayes
    v = votes.group_by { |v| v.value }
    aye_count = (v[:aye] ? v[:aye].count : 0)
    nay_count = (v[:nay] ? v[:nay].count : 0)
    present_count = (v[:present] ? v[:present].count : 0)
    abstain_count = (v[:abstain] ? v[:abstain].count : 0)
    {:ayes => aye_count, :nays => nay_count, :abstains => abstain_count, :presents => present_count}
  end

end
