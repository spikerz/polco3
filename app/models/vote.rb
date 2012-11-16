#require 'mongoid/counter_cache'

class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, :type => Symbol # can be :aye, :nay, :abstain, :present
  field :chamber, :type => Symbol # can be :house, :senate

  has_and_belongs_to_many :polco_groups, index: true #, inverse_of: :votes

  belongs_to :user, index: true
  belongs_to :roll, index: true

  attr_accessible :value, :chamber, :polco_group_ids, :user_id, :roll_id, :followed_group_ids, :state_id, :district_id
  #  value: :aye, chamber: :senate, polco_group_ids: ["50a4508bf11aac56bd00000c"], user_id: nil, roll_id: "50a450f9f11aac56bd00000f">

  after_create :save_chamber # or before_save ??

  # what we don't want is a repeated vote, so that would be a bill_id, polco_group and user_id
  validates_uniqueness_of :user_id, :scope => [:polco_group_id, :roll_id], :message => "this vote already exists"
  validates_presence_of :value, :user_id, :roll_id, :message => "A value must be included"
  validates_inclusion_of :value, :in => VOTE_VALUES, :message => 'You can only vote yes, no or abstain'

  #has_many :followers, :class_name => "User"
  def save_chamber
    self.chamber = self.roll.bill.chamber
  end

end
