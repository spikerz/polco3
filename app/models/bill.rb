class Bill
  include Mongoid::Document

  field :govtrack_id, type: String
  field :bill_resolution_type, type: String
  field :bill_type, type: String
  field :congress, type: Integer
  field :current_status, type: String
  field :current_status_label, type: String
  field :current_status_date, type: Date
  field :current_status_description, type: String
  field :display_number, type: String
  field :docs_house_gov_postdate, type: Date
  field :introduced_date, type: Date
  field :is_alive, type: Boolean
  field :is_current, type: Boolean
  field :link, type: String
  field :number, type: Integer
  field :resource_uri, type: String
  field :senate_floor_schedule_postdate, type: Date
  field :thomas_link, type: String
  field :title, type: String
  field :title_without_number, type: String

  # my additions
  field :bill_html, :type => String
  field :ident, :type => String
  field :cosponsors_count, :type => Integer
  field :govtrack_name, type: String
  field :summary_word_count, :type => Integer
  field :text_word_count, :type => Integer
  field :text_updated_on, :type => Date
  field :hidden, :type => Boolean
  field :roll_time, :type => DateTime

  index({ title: 1}, {unique: true})
  index({ bill_type: 1}, {unique: true})
  index({ created_at: 1}, {unique: true})
  index({ govtrack_name: 1}, {unique: true})
  index({ roll_time: 1}, {unique: true})

  # #####################
  # SCOPES
  scope :house_bills, where(title: /^h/).desc(:vote_count)
  scope :senate_bills, where(title: /^s/).desc(:vote_count)
  scope :introduced_house_bills, where(title: /^h/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :introduced_senate_bills, where(title: /^s/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :rolled_bills, where(:roll_time.ne => nil).descending(:roll_time)

  # #####################
  # ASSOCIATIONS

  belongs_to :sponsor, :class_name => "Legislator"

  has_and_belongs_to_many :cosponsors, :class_name => "Legislator"
  has_and_belongs_to_many :subjects

  has_many :rolls

  # #####################
  # METHODS

  def current_status_explanation
    CURRENT_STATUS[self.current_status]
  end

  def passed?
    !(self.current_status =~ /^pass/).nil?
  end

  def get_bill_text
    HTTParty.get("#{GOVTRACK_URL}data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html").response.body
  end

  class << self

    def pull_in_bills(congress = 112, limit = 100)
      GovTrack::Bill.find(congress: congress, order_by: "-current_status_date", limit: limit).each do |bill|
        puts "Pulling in #{bill.title}"
        from_govtrack(bill).save!
      end
    end

    def from_govtrack(bill)
      b = Bill.new
      b.govtrack_id = bill.id
      b.bill_resolution_type = bill.bill_resolution_type
      b.bill_type = bill.bill_type
      b.congress = bill.congress.to_i
      b.current_status = bill.current_status
      b.current_status_date = bill.current_status_date
      b.current_status_description = bill.current_status_description
      b.display_number = bill.display_number
      b.docs_house_gov_postdate = Date.parse(bill.docs_house_gov_postdate.to_s) if bill.docs_house_gov_postdate
      b.introduced_date = Date.parse(bill.introduced_date.to_s)
      b.is_alive = bill.is_alive
      b.is_current = bill.is_current
      b.link = bill.link
      b.number = bill.number
      b.resource_uri = bill.resource_uri
      b.senate_floor_schedule_postdate = bill.senate_floor_schedule_postdate
      b.thomas_link = bill.thomas_link
      b.title = bill.title
      b.title_without_number = bill.title_without_number
      # lookup
      # add legislator if they don't exist?
      if legislator = Legislator.where(govtrack_id: bill.sponsor.id).first
        b.sponsor = legislator
      else
        legislator = Legislator.find_and_build(bill.sponsor.id)
        legislator.save!
        b.sponsor = legislator
        #raise "sponsor not found"
      end
      # add rolls ?
      GovTrack::Vote.find(related_bill: bill.id, order_by: "-created").each do |vote|
        roll = Roll.from_govtrack(vote)
        roll.add_votes
        b.rolls << roll
      end
      b
    end
  end

  ############################################################################################################
  #########################################      OLD METHODS        ##########################################
  ############################################################################################################

  #def rolled
  #  !self.roll_time.nil?
  #end
  #

  #def chamber
  #  self.title[0] == "h" ? :house : :senate
  #end

  # ------------------- Public booher_modules aggregation methods -------------------

  #def full_type
  #  case self.bill_type
  #    when 'h' then
  #      'H.R.'
  #    when 'hr' then
  #      'H.Res.'
  #    when 'hj' then
  #      'H.J.Res.'
  #    when 'hc' then
  #      'H.C.Res.'
  #    when 's' then
  #      'S.'
  #    when 'sr' then
  #      'S.Res.'
  #    when 'sj' then
  #      'S.J.Res.'
  #    when 'sc' then
  #      'S.C.Res.'
  #  end
  #end

  #def update_legislator_counts
  #  unless self.sponsor.nil?
  #    self.sponsor.update_attribute(:sponsored_count, self.sponsor.sponsored.length)
  #  end
  #  cosponsors.each do |cosponsor|
  #    cosponsor.update_attribute(:cosponsored_count, cosponsor.cosponsored.length)
  #  end
  #  if self.hidden?
  #    self.sponsor = nil
  #    self.cosponsors = []
  #    self.bill_html = nil
  #  end
  #end

  #def get_latest_action
  #  last_action = self.bill_actions.sort_by { |dt, tit| dt }.last
  #  {:date => last_action.first, :description => last_action.last}
  #end

  #def status_description
  #  BILL_STATE[self.bill_state.gsub(":", "|")]
  #end


  #def save_sponsor(id)
  #  if sponsor = Legislator.where(:govtrack_id => id).first
  #    self.sponsor = sponsor
  #  else
  #    raise "sponsor not in database!"
  #  end
  #  self.save
  #end

  #def save_cosponsors(cosponsors)
  #  cosponsors.each do |cosponsor_id|
  #    cosponsor = Legislator.where(:govtrack_id => cosponsor_id).first
  #    if cosponsor
  #      self.cosponsors << cosponsor
  #    else
  #      raise "cosponsor not found"
  #    end
  #  end
  #  self.save
  #end

  #def get_titles(raw_titles)
  #  titles = Array.new
  #  raw_titles.each_slice(2) do |title|
  #    titles.push title
  #  end
  #  titles
  #end
  #
  #def get_actions(raw_actions)
  #  # what are the actions? next steps for the bill, right?
  #  actions = Array.new
  #  raw_actions.each_slice(2) do |action|
  #    actions.push action
  #  end
  #  actions.sort_by { |d, a| d }.reverse
  #end

  #def rolled?
  #  !self.roll_time.nil?
  #end

  # eieio -- this is the "last" vote summary
  #def vote_summary
  #  self.rolls.last.tally if self.rolled?
  #end

  #private

  #def self.bill_search(search)
  #  if search
  #    self.where(short_title: /#{search}/i) if search
  #  else
  #    self.all
  #  end
  #end

#   Bill files are named as follows: data/us/CCC/rolls/TTTNNN.xml.

#      CCC signifies the Congress number. See the first column of data/us/sessions.tsv. It is a number from 1 to 112 (at the time of writing) without zero-padding.
#      TTT is the type of bill or resolution from the following codes: "h" (displayed "H.R." i.e. a House bill), "hr" (displayed "H.Res.", a House resolution), "hj" (displayed "H.J.Res." i.e. a House joint resolution), "hc" (displayed "H.Con.Res.", i.e. a House Concurrent Resolution), and similarly "s", "sr", "sj", and "sc" for Senate bills displayed as "S.", "S.Res.", "S.J.Res.", and "S.Con.Res."



end
