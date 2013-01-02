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

  attr_accessible :provider, :uid, :name, :email, :custom_group_ids, :followed_group_ids, :state_id, :district_id
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ email: 1 }, { unique: true, background: true })

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

  # crazy number of associations
  has_many :votes
  #has_many :custom_groups, class_name: "PolcoGroup", inverse_of: :owner
  belongs_to :district, class_name: "PolcoGroup", inverse_of: :constituents
  belongs_to :state, class_name: "PolcoGroup", inverse_of: :state_constituents
  has_and_belongs_to_many :custom_groups, class_name: "PolcoGroup", inverse_of: :members
  has_and_belongs_to_many :common_groups, class_name: "PolcoGroup", inverse_of: :common_members
  has_and_belongs_to_many :followed_groups, class_name: "PolcoGroup", inverse_of: :followers
  has_and_belongs_to_many :senators, class_name: "Legislator", inverse_of: :state_constituents
  belongs_to :representative, class_name: "Legislator", inverse_of: :district_constituents

  # a user can only join or follow a group once
  validates :custom_group_ids, :allow_blank => true, :uniqueness => true
  validates :followed_group_ids, :allow_blank => true, :uniqueness => true
  validates :email, :email => true

  #before_create :assign_default_group


  # attributes
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
    self.district = PolcoGroup.find_district(district).first
    self.add_baseline_groups(us_state, district)
    self.geocoded = true
    #self.role = :registered # 7 = registered (or 6?)
    self.save!
  end

  def add_baseline_groups(us_state, district)
    self.district = PolcoGroup.where(name: district, type: :district).first
    self.state = PolcoGroup.where(name: us_state, type: :state).first
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

  def build_address(params)
    if params[:zip]
      "#{params[:street_address].strip}, #{params[:city].strip}, #{params[:state].strip}, #{params[:zip].strip}"
    else
      "#{params[:street_address].strip}, #{params[:city].strip}, #{params[:state].strip}"
    end
  end

  class << self

    API_URL = "http://services.sunlightlabs.com/api/"
    API_FORMAT = "json"
    API_KEY = '92c20ab595eb497094652016086760ea' # yeah, it's here feel free to use it

    def build_coords(input, district_name)
      input = DISTRICT_CENTERS[district_name] unless input
      "#{input.first},#{input.last}"
    end

    def build_coords_simple(input)
      #input = get_district_center(district_name) unless input
      "#{input.first},#{input.last}"
    end

    def get_districts_by_zipcode(zip)
      method = 'districts.getDistrictsFromZip'
      if response = HTTParty.get(User.construct_sunlight_url(method,{zip: zip}))['response']
        districts = response['districts']
      else
        raise "no response from sunlight"
      end
      districts.map{|d| "#{d['district']['state']}#{"%02d" % d['district']['number'].to_i}"}
    end

    def get_district_from_coords(coords)
      lat, lon = coords # .first, coords.last
      if response = HTTParty.get(User.construct_sunlight_url('districts.getDistrictFromLatLong',{latitude: lat, longitude: lon}))['response']
        district = response['districts'].first['district']
      else
        raise "no response from sunlight"
      end
      "#{district['state']}#{"%02d" % district['number'].to_i}"
    end

    def get_members(members)
      legs = []
      members.each do |member|
        # need to clear previous members
        if leg = Legislator.where(:govtrack_id => member.govtrack_id).first
          legs << leg
        else
          puts "adding legislator"
          legislator = Legislator.find_and_build(member.govtrack_id)
          legislator.save!
          legs << legislator
          #raise "legislator #{member.govtrack_id} not found"
        end
      end
      # TODO -- mongo this
      senators = legs.select { |l| l.title == 'Sen.' }.sort_by { |u| u.start_date }
      members = Hash.new
      members[:senior_senator] = senators.first
      members[:junior_senator] = senators.last
      members[:representative] = (legs - senators).first
      members
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
