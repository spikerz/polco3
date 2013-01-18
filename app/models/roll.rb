class Roll

  # this is known as a Vote in the GovTrack API!
  include Mongoid::Document
  include VotingLogic
  include VotingMethods
  include ActionView::Helpers::TextHelper
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

  field :vote_count, type: Integer, default: 0

  scope :most_popular, desc(:vote_count).limit(10)
  scope :house_rolls, where(chamber: :house, :bill_id.exists => true).desc(:vote_count)
  scope :senate_rolls, where(chamber: :senate, :bill_id.exists => true).desc(:vote_count)

  #def house_rolls
  #  Roll.where(chamber:
  #end

  # associations
  belongs_to :bill
  has_many :legislator_votes
  has_many :votes
  has_many :comments, as: :commentable

  # [:aye, :nay, :abstain, :present]
  VAL = {'+' => :aye, '-' => :nay, 'P' => :present, '0' => :abstain}

  def name
    self.the_question
  end

  def district_votes
    Vote.where(roll_id: self.id).groups.select{|v| v.votable.type == :district}.map{|v2| v2.votable}
  end

  def category_description
    ROLL_CATEGORIES[self.category][:description]
  end

  def category_label
    ROLL_CATEGORIES[self.category][:label]
  end

  def tally
    {:ayes => self.aye, :nays => self.nay, :other => self.other}
  end

  def title
    self.the_question
  end

  def short_title
    if self.the_question =~ /(.*?):/
      q = $1
    else
      q = self.the_question
    end
    truncate(q, length: 30)
  end

  def add_votes(voter_limit = 500)
    # from mongo docs: If the parent is persisted, then the child documents will be automatically saved.
    GovTrack::VoteVoter.find(vote: self.govtrack_id, limit: voter_limit).each do |vote_voter|
      puts "Adding #{vote_voter.vote_description} for #{vote_voter.person_name} who voted #{vote_voter.option}"
      l = LegislatorVote.from_govtrack(vote_voter)
      self.legislator_votes << l
    end
    self.save
  end

  def senators_votes(state)
    votes = []
    state.senators.each do |s|
      if vote = LegislatorVote.where(legislator_id: s.id).and(roll_id: self.id).first
        votes.push("#{vote.legislator.name_no_details}: #{vote.value}")
      end
    end
    votes.join(", ")
  end

  class << self

    def pull_in_votes(limit = 150, voter_limit = 500)
      GovTrack::Vote.find(order_by: "-created", limit: limit, congress: 113).each do |vote|
        if !Roll.where(govtrack_id: vote.id).exists? && vote.vote_type != "Quorum Call"
          puts "Pulling in #{vote.question}"
          roll = from_govtrack(vote)
          roll.save
          roll.add_votes(voter_limit)
        else
          puts "skipping #{vote.question} from #{vote.resource_uri}"
        end
      end
    end

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
      if go.related_bill
        unless bill = Bill.where(govtrack_id: go.related_bill.id).first
          bill = Bill.from_govtrack GovTrack::Bill.find_by_id(go.related_bill.id)
          bill.save!
        end
        r.bill = bill
      else
        puts "no related bill for #{r.the_question}"
      end
      r
    end

  end

end
