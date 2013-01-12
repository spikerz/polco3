class Vote
  # this records a polco user's vote on a roll
  # bleeding edge, counter cache in: https://github.com/mongoid/mongoid/pull/2665

  include Mongoid::Document
  include Mongoid::Timestamps
  include VotingMethods

  field :value, :type => Symbol # can be :aye, :nay, :abstain, :present
  field :chamber, :type => Symbol # can be :house, :senate

  belongs_to :votable, polymorphic: true

  #has_and_belongs_to_many :polco_groups, index: true, inverse_of: :votes

  #belongs_to :user, index: true
  belongs_to :roll, index: true

  scope :users, where(votable_type: "User")
  scope :groups, where(votable_type: "PolcoGroup")

  attr_accessible :value, :chamber, :roll_id
  #  value: :aye, chamber: :senate, polco_group_ids: ["50a4508bf11aac56bd00000c"], user_id: nil, roll_id: "50a450f9f11aac56bd00000f">

  #after_create :save_chamber # or before_save ??

  # what we don't want is a repeated vote, so that would be a bill_id, polco_group and user_id
  #validates_uniqueness_of :user_id, :scope => [:roll_id], :message => "this vote already exists"
  validates_presence_of :value, :roll_id, :message => "A value and roll must be included"
  validates_inclusion_of :value, :in => VOTE_VALUES, :message => 'You can only vote yes, no or abstain'
  # still need uniqueness validation

  def district_tally
    # we want to find all the votes on roll 'r' and this district
    if self.votable_type == "User"
      h = process_votes(self.votable.district.votes.where(roll_id: self.roll.id))
      "<span class=\"green\">#{h[:ayes]}</span>, <span class=\"orange\">#{h[:abstains] + h[:presents]}</span>, <span class=\"red\">#{h[:nays]}".html_safe
    end
  end

  def reps_vote
    if self.votable_type == "User"
      self.votable.reps_vote_on(self.roll)
    end
  end

end
