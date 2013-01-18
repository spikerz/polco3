class LegislatorVote
  include Mongoid::Document

  field :value, :type => Symbol
  field :created, type: Date
  field :link, type: String
  field :option, type: String
  field :vote_reference, type: String
  field :voter_type, type: Integer
  field :resource_uri, type: String
  field :vote_description, type: String

  belongs_to :legislator
  belongs_to :roll

  VOTER_TYPE = {1 => "Vice President", 2 => "Unknown", 3 => "Member of Congress"}

  def vote_result
    case self.option
      when "+"
        :aye
      when "-"
        :nay
      else
        :other
    end
  end

  class << self
    def from_govtrack(gt_o)
      l = LegislatorVote.new
      l.created = Date.parse(gt_o.created.to_s)
      l.link    = gt_o.link
      l.option  = gt_o.option
      l.resource_uri = gt_o.resource_uri
      l.vote_description = gt_o.vote_description
      l.voter_type = find_voter_type(gt_o.voter_type)
      l.legislator = Legislator.where(govtrack_id: gt_o.person.id).first # legislator
      #l.roll = Roll.where(govtrack_id: gt_o.vote.id).first # roll
      l.value = l.vote_result
      #l = gt_o.person_name
      l
    end

    def find_voter_type(vt)
      case vt
        when "vice_president"
          1
        when "unknown"
          2
        else
          3
      end
    end

  end

end
