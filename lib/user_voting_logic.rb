module UserVotingLogic
  # eieio
  # i don't think rolls could be voted on . . .
  def rolls_voted_on(chamber)
    Roll.any_in(_id: Vote.where(user_id: self.id).and(chamber: chamber).map(&:roll_id))
  end

  # eieio used?
  #
  def record_vote_for_state_and_district(roll_id, value)
    if self.district.nil? || self.state.nil?
      raise "#{self.name} must have an assigned state and district"
    else
      [self.district, self.state].each do |polco_group|
        Vote.create!(user_id: self.id, roll_id: roll_id, value: value, polco_group_id: polco_group.id)
      end
    end
  end

  # eieio -- same logic
  def rolls_not_voted_on(chamber)
    ids = Vote.where(user_id: self.id).map{|v| v.roll.id }
    if chamber == :house
      Roll.house_rolls.not_in(_id: ids).desc(:vote_count)
    else
      Roll.senate_rolls.not_in(_id: ids).desc(:vote_count)
    end
  end

  # eieio
  def find_10_rolls_not_voted_on
    ids = Vote.where(user_id: self.id).map{|v| v.roll.id }
    Roll.not_in(_id: ids).limit(10)
  end

  def us_state
    self.state.name if self.state
  end

  # eieio
  # this needs to run off of roll
  def reps_vote_on(house_roll)
    if house_roll.rolled?
      if leg = self.representative
        house_roll.find_member_vote(leg).to_s
      end
    else
      "Vote has not yet occured"
    end
  end

  # eieio
  # this needs to run on roll
  def senators_vote_on(b)
    unless self.senators.empty?
      votes = []
      self.senators.each do |senator|
        if vote = LegislatorVote.where(legislator_id: senator.id).and(roll_id: b.id).first
        votes.push({name: vote.legislator.full_name, value: vote.value})
        end
      end
      votes
    end
  end
end