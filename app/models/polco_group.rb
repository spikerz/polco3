class PolcoGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  include VotingMethods

  attr_accessible :name, :type, :description, :vote_count, :follower_count, :member_count, :owner_id, :member_ids, :common_member_ids, :follower_ids, :vote_ids

  field :name, :type => String
  field :type, :type => Symbol, :default => :custom
  field :description, :type => String
  field :vote_count, :type => Integer, :default => 0
  field :follower_count, :type => Integer, :default => 0
  field :member_count, :type => Integer, :default => 0

  index({ name: 1}, {unique: true})
  index({ type: 1}, {unique: true})
  index({ follower_count: 1}, {unique: true})
  index({ member_count: 1}, {unique: true})
  index({ vote_count: 1}, {unique: true})

  belongs_to :owner, :class_name => "User", :inverse_of => :custom_groups

  has_many :constituents, class_name: "User", inverse_of: :district
  has_many :state_constituents, class_name: "User", inverse_of: :state

  has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :custom_groups # uniq: true
  has_and_belongs_to_many :common_members, :class_name => "User", :inverse_of => :common_groups # uniq: true
  has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups #, uniq: true
  has_and_belongs_to_many :votes, index: true # , inverse_of: :polco_groups

  # you can only join and follow a group once
  #validates_uniqueness_of :members, message: "User has already joined this group"
  #validates_uniqueness_of :followers, message: "User has already joined this group"

  def get_tally
    # TODO what does this mean in the context of a group?
    process_votes(self.votes)
  end

  def add_member(user_obj)
    self.members.push(user_obj)
    self.member_count += 1
    self.save
  end

  #we want to increment member_count when a new member is added
  #before_save :update_followers_and_members

  # some validations
  validates_uniqueness_of :name, :scope => :type
  validates_inclusion_of :type, :in => [:custom, :state, :district, :common, :country], :message => 'Only valid groups are custom, state, district, common, country'

  scope :states, where(type: :state)
  scope :districts, where(type: :district).desc(:member_count)
  scope :districts_with_activity, where(type: :district).and(:vote_count.gt => 0).desc(:member_count)
  scope :customs, where(type: :custom)
  scope :most_followed, desc(:follower_count)
  scope :most_members, desc(:member_count)
  scope :most_votes, desc(:vote_count)
  scope :find_district, ->(district_name) { where(type: :district).and(name: district_name) }

  # time to create the ability to follow
  before_update :update_counters

  def update_counters
    #self.reload
    #puts "follower size #{self.follower_ids.size}"
    self.follower_count = self.follower_ids.size
    #puts "member size #{self.member_ids.size}"
    self.member_count = self.member_ids.size
    self.vote_count = self.votes.size
    puts "now followers #{self.follower_count} and members #{self.member_count} for #{self.name}"
    puts "is the model valid #{self.valid?}"
  end

  def has_activity?(roll)
    # does the group have any polco activity?
    self.votes.where(roll_id: roll.id).size > 0
  end

  def the_rep
    # this method finds the rep of a district
    if self.type == :district && self.name
      if self.name =~ /([A-Z]{2})-AL/ # then there is only one district
        puts "The district is named #{self.name}"
        l = Legislator.where(state: $1).where(district: 0).first
      else # we have multiple districts for this state
        data = self.name.match(/([A-Z]+)(\d+)/)
        state, district_num = data[1], data[2].to_i
        l = Legislator.representatives.where(state: state).and(district: district_num).first
        #l = Legislator.all.select { |l| l.district_name == self.name }.first
      end
    else
      l = "Only districts can have a representative"
    end
    l || "Vacant"
  end

  def get_votes_tally(roll)
    # messy!
    process_votes(self.votes.where(roll_id: roll.id).all.to_a)
  end

  def format_votes_tally(roll)
    v = process_votes(self.votes.where(roll_id: roll.id).all.to_a)
    "#{v[:ayes]}, #{v[:nays]}, #{v[:abstains]}"
  end

  def senators
    if self.type == :state
      Legislator.senators.where(state: self.name).all.to_a
    else
      nil
    end
  end

  def senators_hash
    if self.type == :state
      legs=Legislator.senators.where(state: self.name).all.to_a.sort_by { |u| u.start_date }
      {junior_senator: legs.last, senior_senator: legs.first}
    else
      nil
    end
  end

end
