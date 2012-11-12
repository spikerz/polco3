class Bill
  include Mongoid::Document

  # initial fields
  field :congress, :type => Integer
  field :bill_number, :type => Integer
  field :bill_type, :type => String
  field :last_updated, :type => Date
  field :bill_state, :type => String #
  field :introduced_date, :type => Date #
  field :title, :type => String
  field :titles, :type => Array #
  field :summary, :type => String #
  field :bill_actions, :type => Array #
  field :bill_html, :type => String
  # things i calculate
  field :ident, :type => String
  field :cosponsors_count, :type => Integer
  field :govtrack_id, :type => String
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

  # scopes . . .
  scope :introduced_house_bills, where(title: /^h/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :introduced_senate_bills, where(title: /^s/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :rolled_bills, where(:roll_time.ne => nil).descending(:roll_time)

  belongs_to :sponsor, :class_name => "Legislator"
  has_and_belongs_to_many :cosponsors, :order => :state, :class_name => "Legislator"
  has_and_belongs_to_many :subjects

  validates_presence_of :govtrack_name

  has_many :rolls

  def rolled
    !self.roll_time.nil?
  end

  # Mongoid::Errors::Validations: Validation failed - Title can't be blank.
  def short_title
    # we show the first short title
    txt = nil
    if self.titles
      the_short_title = self.titles.select { |type, txt| type == 'short' }
      unless the_short_title.empty?
        txt = the_short_title.first.last
      end
    else
      Rails.logger.warn "no titles for #{self.ident}"
    end
    txt
  end

  def chamber
    self.title[0] == "h" ? :house : :senate
  end

  def long_title
    txt = nil
    if self.titles
      official_title = self.titles.select { |type, txt| type == 'official' }
    else
      raise "No official title for #{self.ident}"
    end
    txt = official_title.first.last unless official_title.empty?
    txt
  end

  def bill_title
    short_title || long_title.truncate(75) || "no title available!"
  end

  def tiny_title
    self.title.capitalize
  end

  # ------------------- Public booher_modules aggregation methods -------------------

  def full_type
    case self.bill_type
      when 'h' then
        'H.R.'
      when 'hr' then
        'H.Res.'
      when 'hj' then
        'H.J.Res.'
      when 'hc' then
        'H.C.Res.'
      when 's' then
        'S.'
      when 'sr' then
        'S.Res.'
      when 'sj' then
        'S.J.Res.'
      when 'sc' then
        'S.C.Res.'
    end
  end

  def full_number
    self.full_type + ' ' + bill_number.to_s
  end

  def passed?
    !(self.bill_state =~ /^PASS_OVER|PASSED|PASS_BACK|ENACTED/).nil?
  end

  def update_legislator_counts
    unless self.sponsor.nil?
      self.sponsor.update_attribute(:sponsored_count, self.sponsor.sponsored.length)
    end
    cosponsors.each do |cosponsor|
      cosponsor.update_attribute(:cosponsored_count, cosponsor.cosponsored.length)
    end
    if self.hidden?
      self.sponsor = nil
      self.cosponsors = []
      self.bill_html = nil
    end
  end

  def get_latest_action
    last_action = self.bill_actions.sort_by { |dt, tit| dt }.last
    {:date => last_action.first, :description => last_action.last}
  end

  def status_description
    BILL_STATE[self.bill_state.gsub(":", "|")]
  end

  def update_bill(force_update = false)
    # this is a critical method . . . (27 April 2012)
    if self.govtrack_name
      file_data = File.new("#{DATA_PATH}/bills/#{self.govtrack_name}.xml", 'r')
    else
      raise "The bill does not have the property govtrack_name."
    end
    bill = Feedzirra::Parser::GovTrackBill.parse(file_data)
    # check for changes
    if (bill && (self.introduced_date.nil? || (bill.introduced_date.to_date > self.introduced_date) || force_update))
      # front-matter
      puts "updating #{self.govtrack_name}"
      self.congress = bill.congress
      self.bill_type = bill.bill_type
      self.bill_number = bill.bill_number
      self.last_updated = bill.last_updated.to_date
      # get titles
      self.ident = "#{self.congress}-#{self.bill_type}#{self.bill_number}"
      self.govtrack_id = "#{self.bill_type}#{self.congress}-#{self.bill_number}"

      # get actions
      self.bill_state = bill.bill_state
      self.introduced_date = bill.introduced_date.to_date

      self.titles = get_titles(bill.titles)
      self.bill_actions = get_actions(bill.bill_actions)
      self.summary = bill.summary

      # update subjects
      self.subjects = []
      bill.subjects.each do |subject|
        self.subjects.push(Subject.find_or_create_by(:name => subject))
      end
      #puts "the bill is valid? #{self.valid?}"

      # sponsors
      save_sponsor(bill.sponsor_id)
      save_cosponsors(bill.cosponsor_ids) unless bill.cosponsor_ids.empty?

      # Yield to a block that can perform arbitrary calls on this bill
      if block_given?
        yield(self)
      end

      # bill text
      get_bill_text if self.bill_html.blank? || self.text_updated_on.blank? || self.text_updated_on < Date.parse(self.bill_actions.first.first)

      self.cosponsors_count = self.cosponsors.count
      self.text_word_count = self.bill_html.to_s.word_count
      self.summary_word_count = self.summary.to_s.word_count
      true
    else
      puts "no need to update #{self.govtrack_name}"
      false
    end

  end

  def get_bill_text
    bill_object = HTTParty.get("#{GOVTRACK_URL}data/us/bills.text/#{self.congress.to_s}/#{self.bill_type}/#{self.bill_type + self.bill_number.to_s}.html")
    self.bill_html = bill_object.response.body
    self.text_updated_on = Date.today
    Rails.logger.info "Updated Bill Text for #{self.ident}"
  end

  def save_sponsor(id)
    if sponsor = Legislator.where(:govtrack_id => id).first
      self.sponsor = sponsor
      # now add this bill to the sponsor
      #self.save
      #sponsor.bills.push(self)
      #sponsor.save!
    else
      raise "sponsor not in database!"
    end
    self.save
  end

  def save_cosponsors(cosponsors)
    cosponsors.each do |cosponsor_id|
      cosponsor = Legislator.where(:govtrack_id => cosponsor_id).first
      if cosponsor
        self.cosponsors << cosponsor
      else
        raise "cosponsor not found"
      end
    end
    self.save
  end

  def get_titles(raw_titles)
    titles = Array.new
    raw_titles.each_slice(2) do |title|
      titles.push title
    end
    titles
  end

  def get_actions(raw_actions)
    # what are the actions? next steps for the bill, right?
    actions = Array.new
    raw_actions.each_slice(2) do |action|
      actions.push action
    end
    actions.sort_by { |d, a| d }.reverse
  end

  # TODO -- need to write ways to get titles and actions for views (but not what we store in the db)

  #def activity?
  #  self.votes.size > 0 || self.rolled?
  #end

  def rolled?
    !self.roll_time.nil?
  end

  # eieio -- this is the "last" vote summary
  def vote_summary
    self.rolls.last.tally if self.rolled?
  end

  private

  def self.bill_search(search)
    if search
      self.where(short_title: /#{search}/i) if search
    else
      self.all
    end
  end

#   Bill files are named as follows: data/us/CCC/rolls/TTTNNN.xml.

#      CCC signifies the Congress number. See the first column of data/us/sessions.tsv. It is a number from 1 to 112 (at the time of writing) without zero-padding.
#      TTT is the type of bill or resolution from the following codes: "h" (displayed "H.R." i.e. a House bill), "hr" (displayed "H.Res.", a House resolution), "hj" (displayed "H.J.Res." i.e. a House joint resolution), "hc" (displayed "H.Con.Res.", i.e. a House Concurrent Resolution), and similarly "s", "sr", "sj", and "sc" for Senate bills displayed as "S.", "S.Res.", "S.J.Res.", and "S.Con.Res."

end
