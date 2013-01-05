class Legislator
  include Mongoid::Document
  include Mongoid::Timestamps

  # the following fields are directly from govtrack

  field :govtrack_id, type: Integer
  field :bioguideid, type: String
  field :birthday, type: Date
  field :firstname, type: String
  field :gender, type: Integer
  field :id, type: String
  field :lastname, type: String
  field :link, type: String
  field :metavidid, type: String
  field :middlename, type: String
  field :name, type: String
  field :name_no_details, type: String
  field :namemod, type: String
  field :nickname, type: String
  field :osid, type: String
  field :pvsid, type: String
  field :resource_uri, type: String
  field :sortname, type: String
  field :twitterid, type: String
  field :youtubeid, type: String

  # fields I add
  field :sponsored_count, :type => Integer
  field :cosponsored_count, :type => Integer

  index({ sortname: 1}, {unique: true})
  index({ govtrack_id: 1}, {unique: true})

  GENDERS = {1 => 'male', 2 => 'female'}

  has_many :bills, :inverse_of => :sponsor
  embeds_many :roles
  embeds_one :current_role, class_name: "Role", inverse_of: :elected_member
  has_many :district_constituents, :class_name => "User", :inverse_of => :representative
  has_many :legislator_votes
  has_and_belongs_to_many :state_constituents, :class_name => "User", :inverse_of => :senators

  has_many :comments, as: :commentable

  # scopes
  scope :representatives, where(title: 'Rep.')
  scope :senators, where(title: 'Sen.')

  def latest_votes
    self.legislator_votes.desc(:updated_time)
  end

  def vote_on(bill)
    LegislatorVote.where(legislator_id: self.id, bill_id: bill.id).first.value.to_sym
  end

  def first_or_nick
    nickname.blank? ? firstname : nickname
  end

  def title
    self.current_role.title
  end

  def chamber
    case title
      when "Rep." then
        "U.S. House of Representatives"
      when "Sen." then
        "U.S. Senate"
      else
        title
    end
  end

  def image_location_small
    "#{PHOTO_PATH}/#{self.govtrack_id}-50px.jpeg"
  end

  def image_location_medium
    "#{PHOTO_PATH}/#{self.govtrack_id}-100px.jpeg"
  end

  def full_name
    "#{first_or_nick} #{lastname}"
  end

  #def full_title
  #  "#{title} #{full_name} (#{party}-#{state})"
  #end

  def state
    self.current_role.state
  end

  def state_name
    state.to_us_state
  end

  class << self

    def update_legislators(limit = 800)
      # this method pulls the GovTrack api for all persons, loads each one into the database
      GovTrack::Person.find(roles__current: "true", limit: limit).each do |legislator|
        puts "working on #{legislator.name}"
        self.save_legislator(legislator)
      end
    end

    def find_and_build(govtrack_id)
      from_govtrack(GovTrack::Person.find_by_id(govtrack_id))
    end

    def save_legislator(person)
      unless Legislator.where(govtrack_id: person.id).exists?
         from_govtrack(person).save!
      end
    end

    def from_govtrack(person)
      leg = Legislator.new
      leg.govtrack_id = person.id.to_i
      leg.bioguideid = person.bioguideid
      leg.birthday = person.birthday
      leg.firstname = person.firstname
      leg.lastname = person.lastname
      leg.link = person.link
      leg.metavidid = person.metavidid
      leg.middlename = person.middlename
      leg.name = person.name
      leg.name_no_details = person.name_no_details
      leg.namemod = person.namemod
      leg.nickname = person.nickname
      leg.osid = person.osid
      leg.pvsid = person.pvsid
      leg.resource_uri = person.resource_uri
      leg.sortname = person.sortname
      leg.twitterid = person.twitterid
      leg.youtubeid = person.youtubeid
      if person.current_role
        leg.current_role = Role.from_govtrack(person.current_role)
      else
        puts "no current role for #{person.name} with govtrack id #{person.id}??"
      end
      leg.gender = self.gender_integer(person.gender)
      person.roles.each do |gt_role|
        leg.roles << Role.from_govtrack(gt_role)
      end
      leg
    end

    def gender_integer(gender)
      if gender == "male"
        1
      else
        2
      end
    end

    def bill_search(search)
      puts search
      if search
        # you have to have a class to perform where on (i think)
        self.where(title: /#{search}/i)
      else
        # does scoped work with mongoid
        self.all
      end
    end

  end # self code

  def district
     self.current_role.district
  end

  def district_name
    "#{self.state}#{"%02d" % self.district.to_i}"
  end

  def members_district
    PolcoGroup.where(type: :district).and(name: self.district_name).first
  end

  def members_state_group
    PolcoGroup.states.where(name: self.state).first
  end

  def party
    self.current_role.party
  end

  def start_date
    self.current_role.startdate
  end

  def is_senator?
    self.current_role.role_type == 3
  end

  def job
    if is_senator?
      "Senator from #{self.state}"
    else
      "Representative from #{self.district_name}"
    end
  end

  def bills_voted_on
    LegislatorVote.where(legislator_id: self.id).only(:bill_id).map(&:bill_id).uniq
  end

  def gender_label
    GENDERS[self.gender]
  end
end
