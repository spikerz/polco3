module VotingLogic

  # this module contains everything related to rolls and voting
  # since all voting happens on rolls, we want to put all voting logic here

  # most important method in the app . . .
  def vote_on(user, value)
    # the user must vote
    unless self.voted_on?(user)
      self.inc(:vote_count,1) # for roll
      self.add_user_vote(user,value)
      self.add_group_votes(user.voting_groups, value)
    else
      Rails.logger.warn "already voted on #{self}"
      puts "already voted on"
      false
    end
  end

  def add_user_vote(user, value)
    user.votes.create(value: value, roll_id: self.id, chamber: self.chamber)
    user.inc(:vote_count,1)
    user.save!
  end

  def add_group_votes(groups, value)
    groups.each do |g|
      g.votes.create(value: value, roll_id: self.id, chamber: self.chamber)
      g.inc(:vote_count,1)
      #puts "*************************"
      #puts "adding votes for #{g.name}, current vote count: #{g.vote_count}"
      #puts "*************************"
      g.save!
    end
  end

  def members_tally
    # TODO needs updated
    # this answers: how did members vote on this roll?
    process_votes(self.member_votes)
  end

  def get_overall_users_vote
    process_votes(self.votes.users)
  end

  def find_member_vote(member)
    # how did the member vote last on this roll?
    #roll = self.rolls.first
    unless self.legislator_votes.empty? #&& self.rolled?
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
    if vote = self.votes.where(votable_id: user.id).and(votable_type: "User").first
      vote.value
    else
      "none"
    end
  end

  def senators_vote

  end

end