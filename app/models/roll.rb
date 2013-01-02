class Roll

  # this is known as a Vote in the GovTrack API!

  include Mongoid::Document
  include VotingLogic
  include VotingMethods
  # DOCUMENTATION: http://www.govtrack.us/developers/api#endpoint_vote

  field :category, type: String
  field :chamber, type: String
  field :chamber_label, type: String
  field :congress, type: Integer
  field :created, type: Date
  field :link, type: String
  field :number, type: Integer
  field :options, type: Hash
  field :the_question, type: String #
  field :required, type: String
  field :resource_uri, type: String
  field :result, type: String
  field :session, type: String
  field :source, type: String
  field :source_label, type: String
  field :source_link, type: String
  field :aye, type: Integer   #
  field :nay, type: Integer   #
  field :other, type: Integer     #
  field :vote_type, type: String
  field :govtrack_id, type: Integer

  #field :chamber, type: String
  #field :session, type: Integer #
  #field :file_name, type: String
  #field :result, type: String #
  #field :required, type: String #
  #field :type, type: String #
  #field :bill_type, type: String #
  #
  #
  ## votes
  #
  #field :year, type: Integer     #
  #field :congress, type: String  #
  ## just added . . . rolls vote
  #field :vote_count, type: Integer, default: 0
  ##
  #field :original_time, type: Time    #
  #field :updated_time, type: Time     #
  # still here for speed . . . (might delete)
  #field :legislator_votes, type: Hash
  scope :most_popular, desc(:vote_count).limit(10)
  scope :house_rolls, where(chamber: :house).desc(:vote_count)
  scope :senate_rolls, where(chamber: :senate).desc(:vote_count)

  # associations
  belongs_to :bill
  has_many :legislator_votes
  has_many :votes

  # [:aye, :nay, :abstain, :present]
  VAL = {'+' => :aye, '-' => :nay, 'P' => :present, '0' => :abstain}

  def category_description
    ROLL_CATEGORIES[self.category][:description]
  end

  def category_label
    ROLL_CATEGORIES[self.category][:label]
  end

  #def create_legislator_votes(roll_call, bill)
  #  #votes_hash = Hash.new
  #  roll_call.each do |v|
  #    if l = Legislator.where(govtrack_id: v.member_id).first
  #      unless LegislatorVote.where(bill_id: bill.id).and(legislator_id: l.id).and(roll_id: self.id).exists?
  #        LegislatorVote.create(bill_id: bill.id, legislator_id: l.id, value: VAL[v.member_vote.to_s], roll_id: self.id)
  #      end
  #      # votes_hash[l.id.to_s] = VAL[v.member_vote.to_s]
  #    else
  #      raise "legislator #{v.member_id} not found"
  #    end
  #  end
  #  #self.legislator_votes = votes_hash
  #end

  def tally
    {:ayes => self.aye, :nays => self.nay, :other => self.other}
  end

  #def record_legislator_votes
  #  # the purpose of this is to build a table that links legislators to votes
  #  self.legislator_votes.each do |vote|
  #    LegislatorVote.create(bill_id: self.bill.id, legislator_id: vote.first, value: vote.last)
  #  end
  #end

  def title
    if self.bill
      self.bill.title
    else
      "no bill"
    end
  end

  def add_votes
    GovTrack::VoteVoter.find(vote: self.govtrack_id, limit: 450).each do |vote_voter|
       puts "Adding #{vote_voter.vote_description}"
       self.legislator_votes << LegislatorVote.from_govtrack(vote_voter)
    end
  end

  class << self

    def from_govtrack(go)
      r = Roll.new
      r.govtrack_id = go.id
      r.category = go.category
      r.chamber = go.chamber
      r.chamber_label = go.chamber_label
      r.congress = go.congress
      r.created = go.created
      r.link = go.link
      r.number = go.number
      r.options = go.options
      r.the_question = go.question
      r.required = go.required
      r.resource_uri = go.resource_uri
      r.result = go.result
      r.session = go.session
      r.source = go.source
      r.source_label = go.source_label
      r.source_link = go.source_link
      r.nay = go.total_minus
      r.other = go.total_other
      r.aye = go.total_plus
      r.vote_type = go.vote_type
      r.bill = Bill.where(govtrack_id: go.related_bill.id).first if go.related_bill
      r
    end

  end

end
