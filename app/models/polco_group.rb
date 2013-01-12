class PolcoGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  include VotingMethods
  #include Origin::Queryable

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

  # this might be trouble, a user might not "own" this if they are just in the custom groups (by the way i understood it)
  belongs_to :owner, :class_name => "User", :inverse_of => :custom_groups

  has_many :constituents, class_name: "User", inverse_of: :district
  has_many :state_constituents, class_name: "User", inverse_of: :state

  has_and_belongs_to_many :members, :class_name => "User", :inverse_of => :joined_groups # uniq: true
  has_and_belongs_to_many :common_members, :class_name => "User", :inverse_of => :common_groups # uniq: true
  has_and_belongs_to_many :followers, :class_name => "User", :inverse_of => :followed_groups #, uniq: true
  # groups have votes just like users do !
  #has_and_belongs_to_many :votes, index: true # , inverse_of: :polco_groups

  has_many :votes, as: :votable

  def get_tally(roll)
    process_votes(self.votes.where(roll_id: roll.id))
  end

  def self.column_names
    self.fields.collect { |field| field[0] }
  end

  def add_member(user_obj)
    self.members.push(user_obj)
    self.member_count += 1
    self.save
  end

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
  #before_update :update_counters

  def update_counters # not currently called . . . !
    self.follower_count = self.follower_ids.size
    self.member_count = self.member_ids.size
    self.vote_count = self.votes.size
  end

  def has_activity?(roll)
    # does the group have any polco activity?
    self.votes.where(roll_id: roll.id).size > 0
  end

  def senators_hash
    # polcoGroup must be a state
    if (self.type == :state) && (Legislator.senators.where(state: self.name).size == 2)
      legs = Legislator.senators.where(state: self.name).sort_by { |u| u.current_role.startdate }
      {junior_senator: legs.last, senior_senator: legs.first}
    else
      nil
    end
  end

  def self.states_with_senators
    collection = []
    PolcoGroup.states.each do |state|
      if h = state.senators_hash
        collection << {state: state, junior_senator: h[:junior_senator], senior_senator: h[:senior_senator]}
      end
    end
    collection
  end

  #def has_senator?
  #  (self.type == :state) && (!self.senators_hash.all? {|k,v| v.nil?})
  #end

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

  def proper_title
    if (self.type == :custom) && !self.name.nil?
      self.name.titlecase
    else
      self.name
    end
  end

end
