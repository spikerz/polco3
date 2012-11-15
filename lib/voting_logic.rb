module VotingLogic

  # this module contains everything related to rolls and voting
  # since all voting happens on rolls, we want to put all voting logic here

  def vote_on(user, value)
    unless self.voted_on?(user)
      #ids = user.custom_group_ids
      #ids.push(user.state.id)
      #ids.push(user.district.id)
      #Vote.create(value: value, user_id: user.id, polco_group_ids: ids.uniq, roll_id: self.id)
      v = Vote.new
      v.value = value
      v.user = user
      v.polco_groups << user.custom_groups
      v.polco_groups << user.common_groups
      v.polco_groups << user.state
      v.polco_groups << user.district
      #v.polco_group_ids = (user.custom_groups + user.common_groups + user.state + user.district).map(&:id)
      # update all groups
      # I don't like this, but the increments work  -- locator for flight NXZORQ
      user.state.inc(:vote_count,1)
      user.district.inc(:vote_count,1)
      user.custom_groups.each do |jg|
        jg.inc(:vote_count,1)
      end
      v.roll = self
      v.save
      self.inc(:vote_count,1)
    else
      Rails.logger.warn "already voted on #{self}"
      puts "already voted on"
      false
    end
  end

  def members_tally
    # TODO needs updated
    # this answers: how did members vote on this roll?
    process_votes(self.member_votes)
  end

  def get_overall_users_vote
    process_votes(self.votes)
  end

  def find_member_vote(member)
    # how did the member vote last on this roll?
    #roll = self.rolls.first
    if !self.legislator_votes.empty? #&& self.rolled?
      if l = self.legislator_votes.where(legislator_id: member.id).first
        l.value.to_sym
      else
        "not found"
      end
    else
      "no votes"
    end
  end

  def voted_on?(user)
    if vote = user.votes.where(roll_id: self.id).first
      vote.value
    end
  end

  def users_vote(user)
    if vote = self.votes.all.select { |v| v.user = user }.first
      vote.value
    else
      "none"
    end
  end

end