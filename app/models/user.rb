class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include UserVotingLogic
  include DistrictCenters

  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  field :geocoded, type: Boolean
  field :coordinates, type: Array
  field :admin, type: Boolean, default: false

  attr_accessible :provider, :uid, :name, :email, :custom_group_ids, :followed_group_ids, :state_id, :district_id, :joined_group_ids
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ email: 1 }, { unique: true, background: true })

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
      end
    end
  end

  # crazy number of associations
  has_many :votes, as: :votable

  belongs_to :district, class_name: "PolcoGroup", inverse_of: :district_citizens
  belongs_to :state, class_name: "PolcoGroup", inverse_of: :state_citizens

  # GROUPS -------------------------------------
  # these groups are groups that users have created -- a user is automatically a member of these
  has_many :custom_groups, class_name: "PolcoGroup", inverse_of: :owner
  # these are groups that all users are in
  has_and_belongs_to_many :common_groups, class_name: "PolcoGroup", inverse_of: :common_members
  # these are groups that a user follows but has not joined
  has_and_belongs_to_many :followed_groups, class_name: "PolcoGroup", inverse_of: :followers
  # these are groups that a user has joined
  has_and_belongs_to_many :joined_groups, class_name: "PolcoGroup", inverse_of: :members

  has_and_belongs_to_many :senators, class_name: "Legislator", inverse_of: :state_constituents
  belongs_to :representative, class_name: "Legislator", inverse_of: :district_constituents

  has_many :comments, as: :commentable

  # a user can only join or follow a group once
  # really should change this to "joined groups"
  validates :custom_group_ids, :allow_blank => true, :uniqueness => true
  validates :joined_group_ids, :allow_blank => true, :uniqueness => true
  validates :followed_group_ids, :allow_blank => true, :uniqueness => true
  #validates :email, :email => true

  # attributes

  #after_save do |user|
  #  # not sure if we need this -- the common group is added with
  #  # default groups
  #  if cg = PolcoGroup.where(type: :common).first
  #    user.common_groups << cg
  #  else
  #    raise "common group does not exist"
  #  end
  #end

  def voting_groups
    # these are the groups that have voting power
    self.custom_groups + self.joined_groups + self.common_groups + [self.district, self.state]
  end

  def votes_in_(group)
    group.votes.where(user)
  end

  def us_state
    self.state.name if self.state
  end

  def titled_name
    self.name.titlecase
  end

  def district_name
    self.district.name if self.district
  end

  def add_members(junior_senator, senior_senator, representative, district, us_state)
    self.senators.push(junior_senator)
    self.senators.push(senior_senator)
    self.representative = representative
    self.add_baseline_groups(us_state, district)
    self.geocoded = true
    #self.role = :registered # 7 = registered (or 6?)
    self.save!
  end

  def has_followed(group)
    self.followed_groups.where(_id: group.id).exists?
  end

  def has_joined(group)
    self.joined_groups.where(_id: group.id).exists?
  end

  def senators_names
    self.senators.map{|s| s.name_no_details }.join(" & ")
  end

  def add_baseline_groups(us_state, district)
    if district = PolcoGroup.where(name: district, type: :district).first
      self.district = district
    else
      raise "district does not exist"
    end
    if state = PolcoGroup.where(name: us_state, type: :state).first
      self.state = state
    else
      raise "state does not exist"
    end
    [['USA', :country],['Polco Common',:common]].each do |name, type|
      g = PolcoGroup.find_or_create_by(:name => name, :type => type)
      #g.members.push(self)
      g.member_count += 1
      self.common_groups.push(g) unless self.common_groups.include?(g)
    end
  end

  def get_ip(ip)
    Geocoder.coordinates(ip)
  end

  class << self

    API_URL = "http://services.sunlightlabs.com/api/"
    API_FORMAT = "json"
    API_KEY = '92c20ab595eb497094652016086760ea' # yeah, it's here feel free to use it

    def build_address(params)
      if params[:zip]
        "#{params[:street_address].strip}, #{params[:city].strip}, #{params[:state].strip}, #{params[:zip].strip}"
      else
        "#{params[:street_address].strip}, #{params[:city].strip}, #{params[:state].strip}"
      end
    end

    def get_data(params)
      case params[:commit]
        when "Yes"
          coords= Geocoder.coordinates(params[:location])
          districts = User.get_district_from_coords(coords)
          method = :ip_lookup
        when "Submit Address"
          coords = Geocoder.coordinates(build_address(params))
          districts = User.get_district_from_coords(coords)
          method = "Successful address lookup"
        #when "Submit Zip Code"
        #  districts = User.get_districts_by_zipcode(params[:zip_code])
        #  method = "Successful zip code lookup"
        ## need to get coords somehow
        else
          districts = nil
      end
      {coords: coords, method: method, districts: districts}
    end

    def build_coords(input, district_name)
      input = DISTRICT_CENTERS[district_name] unless input
      "#{input.first},#{input.last}"
    end

    def build_coords_simple(input)
      #input = get_district_center(district_name) unless input
      "#{input.first},#{input.last}"
    end

    #def get_districts_by_zipcode(zip)
    #  method = 'districts.getDistrictsFromZip'
    #  if response = HTTParty.get(User.construct_sunlight_url(method,{zip: zip}))['response']
    #    districts = response['districts']
    #  else
    #    raise "no response from sunlight"
    #  end
    #  districts.map{|k| k['district']}.map{|d| {district: d_format(d), state: d['state']}}
    #end

    def get_district_from_coords(coords)
      lat, lon = coords # .first, coords.last
      if response = HTTParty.get(User.construct_sunlight_url('districts.getDistrictFromLatLong',{latitude: lat, longitude: lon}))['response']
        district = response['districts'].first['district']
      else
        raise "no response from sunlight"
      end
      {district: d_format(district), state: district['state']}
    end

    def d_format(district)
      # format the district like "VA08"
      "#{district['state']}#{"%02d" % district['number'].to_i}"
    end

    def get_members_from_(coords)
      lat, lon = coords
      method = 'legislators.allForLatLong'
      if response = HTTParty.get(User.construct_sunlight_url(method,{latitude: lat, longitude: lon}))['response']
        members = Hash.new
        response['legislators'].map{|l| {id: l['legislator']['govtrack_id'],
                                         district: l['legislator']['district']}}.each do |leg|
          # need to clear previous members
          unless legislator = Legislator.where(:govtrack_id => leg[:id]).first
            puts "adding legislator"
            legislator = Legislator.find_and_build(leg[:id])
            legislator.save!
          end
          members[find_role(leg[:district])] = legislator
        end
        members
      else
        raise "no response from sunlight"
      end
    end

    def find_role(d)
      case d
        when "Junior Seat"
          :junior_senator
        when "Senior Seat"
          :senior_senator
        else
          :representative
      end
    end

    # Constructs a Sunlight API-friendly URL
    def construct_sunlight_url(api_method, params)
      "#{API_URL}#{api_method}.#{API_FORMAT}?apikey=#{API_KEY}#{hash2get(params)}"
    end

    # Converts a hash to a GET string
    def hash2get(h)

      get_string = ""

      h.each_pair do |key, value|
        get_string += "&#{key.to_s}=#{CGI::escape(value.to_s)}"
      end

      get_string

    end # def hash2get

  end



end
