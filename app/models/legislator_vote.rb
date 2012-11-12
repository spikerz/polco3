class LegislatorVote
  include Mongoid::Document
  field :value, :type => String
  belongs_to :legislator
  belongs_to :roll
  belongs_to :bill

end
