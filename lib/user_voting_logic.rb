module UserVotingLogic

  def rolls_voted_on(chamber)
    roll_ids = Vote.where(votable_id: self.id).and(votable_type: "User").and(chamber: chamber.to_sym).map(&:roll_id)
    Roll.any_in(_id: roll_ids)
  end

  def rolls_not_voted_on(chamber)
    ids = Vote.where(user_id: self.id).map{|v| v.roll.id }
    if chamber == :house
      Roll.house_rolls.not_in(_id: ids).desc(:vote_count)
    else
      Roll.senate_rolls.not_in(_id: ids).desc(:vote_count)
    end
  end

  def find_10_rolls_not_voted_on
    ids = Vote.where(user_id: self.id).map{|v| v.roll.id }
    Roll.not_in(_id: ids).limit(10)
  end

  def us_state
    self.state.name if self.state
  end

  def reps_vote_on(house_roll)
    if leg = self.representative
      house_roll.find_member_vote(leg).to_s
    end
  end

  def senators_vote_on(r)
    unless self.senators.empty?
      votes = []
      self.senators.each do |senator|
        if vote = LegislatorVote.where(legislator_id: senator.id).and(roll_id: r.id).first
        votes.push({name: vote.legislator.full_name, value: vote.value})
        end
      end
      votes
    end
  end

end