#require 'mongoid/counter_cache'

class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, :type => Symbol # can be :aye, :nay, :abstain, :present
  field :chamber, :type => Symbol # can be :house, :senate

  has_and_belongs_to_many :polco_groups, index: true
  belongs_to :user, index: true
  belongs_to :roll, index: true

  before_save :save_chamber

  # what we don't want is a repeated vote, so that would be a bill_id, polco_group and user_id
  validates_uniqueness_of :user_id, :scope => [:polco_group_id, :bill_id], :message => "this vote already exists"
  validates_presence_of :value, :user_id, :roll_id, :message => "A value must be included"
  validates_inclusion_of :value, :in => VOTE_VALUES, :message => 'You can only vote yes, no or abstain'

  #has_many :followers, :class_name => "User"
  def save_chamber
    self.chamber = self.roll.bill.chamber
  end

end
