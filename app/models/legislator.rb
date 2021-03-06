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
  # populated
  field :chamber, type: Symbol
  field :state, type: String
  field :district, type: String

  # fields I add
  field :sponsored_count, :type => Integer
  field :cosponsored_count, :type => Integer

  index({ sortname: 1}, {unique: true})
  index({ govtrack_id: 1}, {unique: true})
  index({ chamber: 1}, {unique: false})

  GENDERS = {1 => 'male', 2 => 'female'}
  CHAMBERS = [:house, :senate, :other]

  has_many :bills, inverse_of: :sponsor
  embeds_many :roles

  belongs_to :legislator_district, class_name: "PolcoGroup", inverse_of: :rep
  belongs_to :legislator_state, class_name: "PolcoGroup", inverse_of: :state_legislators

  embeds_one :current_role, class_name: "Role", inverse_of: :elected_member

  has_many :legislator_votes

  has_and_belongs_to_many :state_constituents, :class_name => "User", :inverse_of => :senators
  has_many :district_constituents, :class_name => "User", :inverse_of => :representative

  has_many :comments, as: :commentable

  # scopes
  scope :representatives, where(chamber: :house)
  scope :senators, where(chamber: :senate)

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

  def chamber_label
    case self.chamber
      when :house then
        "U.S. House of Representatives"
      when :senate then
        "U.S. Senate"
      else
        "Other"
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

  def current_state
    self.current_role.state
  end

  def state_name
    current_state.to_us_state
  end

  class << self

    def update_legislators(limit = 800)
      # this method pulls the GovTrack api for all persons, loads each one into the database
      GovTrack::Person.find(roles__current: "true", limit: limit).each do |legislator|

        unless Legislator.where(govtrack_id: legislator.id).exists?
          puts "working on #{legislator.name}"
          self.save_legislator(legislator)
        else
          puts "skipping #{legislator.name} because they exist"
        end
      end
    end

    def assign_districts
      Legislator.all.each do |l|
        if d = PolcoGroup.districts.where(name: l.district_name).first
          puts "Assigning #{d.name} to #{l.name}"
          l.legislator_district = d
          d.rep = l
          l.save!
          d.save!
        end
      end
      true
    end

    def find_and_build(govtrack_id)
      from_govtrack(GovTrack::Person.find_by_id(govtrack_id))
    end

    def save_legislator(person)
      unless Legislator.where(govtrack_id: person.id).exists?
         from_govtrack(person).save!
      end
    end

    #def update_current_role
    #  Legislator.all.each do |leg|
    #    person = GovTrack::Person.find_by_id(leg.govtrack_id)
    #    if person.current_role
    #      puts "updating #{leg.name}"
    #      leg.current_role = Role.from_govtrack(person.current_role)
    #      leg.state = person.current_role.state
    #      leg.chamber = find_chamber(person.current_role.title)
    #      leg.district = person.current_role.district.to_s
    #      leg.save!
    #    else
    #      puts "no current role for #{person.name} with govtrack id #{person.id}??"
    #    end
    #  end
    #  puts "Update successful"
    #end

    def from_govtrack(person)
      leg = Legislator.new
      leg.govtrack_id = person.id.to_i
      leg.bioguideid = person.bioguideid
      leg.birthday = person.birthday
      leg.firstname = person.firstname
      leg.lastname = person.lastname
      leg.link = person.link
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
        leg.state = person.current_role.state
        leg.chamber = find_chamber(person.current_role.title)
        leg.district = person.current_role.district.to_s
      else
        puts "no current role for #{person.name} with govtrack id #{person.id}??"
      end
      leg.gender = self.gender_integer(person.gender)
      person.roles.each do |gt_role|
        leg.roles << Role.from_govtrack(gt_role)
      end
      # now assign the legislator to a district
      if leg.chamber == :house
        d = PolcoGroup.find_or_create_by(type: :district, name: leg.district_name)
        leg.legislator_district = d
        d.rep = leg
        d.save!
      end
      unless leg.chamber == :other
        s = PolcoGroup.find_or_create_by(type: :state, name: leg.state)
        leg.legislator_state = s
        s.state_legislators << leg
        s.save!
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

    def find_chamber(title)
      case title
        when "Rep." then
          :house
        when "Sen." then
          :senate
        else
          :other
      end
    end

  end # self code


  #def district
  #   self.current_role.district
  #end

  def district_name
    unless self.chamber == :senate
      if self.district == "0"
        "#{self.state}-AL"
      else
        "#{self.state}#{"%02d" % self.district.to_i}"
      end
    else

    end
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
