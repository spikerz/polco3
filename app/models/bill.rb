class Bill
  include Mongoid::Document

  field :title, type: String
  field :title_without_number, type: String
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

  # my additions
  #field :bill_html, :type => String
  field :ident, :type => String
  field :cosponsors_count, :type => Integer
  field :govtrack_name, type: String
  field :summary_word_count, :type => Integer
  field :text_word_count, :type => Integer
  field :text_updated_on, :type => Date
  field :hidden, :type => Boolean
  field :roll_time, :type => DateTime

  index({title: 1}, {unique: true})
  index({bill_type: 1}, {unique: true})
  index({created_at: 1}, {unique: true})
  index({govtrack_name: 1}, {unique: true})
  index({roll_time: 1}, {unique: true})

  # #####################
  # SCOPES
  scope :house_bills, where(title: /^h/).desc(:vote_count)
  scope :senate_bills, where(title: /^s/).desc(:vote_count)
  scope :introduced_house_bills, where(title: /^h/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :introduced_senate_bills, where(title: /^s/).and(bill_state: /^INTRODUCED|REPORTED|REFERRED$/).desc(:introduced_date)
  scope :rolled_bills, where(:roll_time.ne => nil).descending(:roll_time)

  # #####################
  # ASSOCIATIONS

  has_many :comments, as: :commentable

  belongs_to :sponsor, :class_name => "Legislator"

  has_and_belongs_to_many :cosponsors, :class_name => "Legislator"
  has_and_belongs_to_many :subjects

  has_many :rolls

  # #####################
  # METHODS

  def type_key
    BILL_TYPE_HASH[self.bill_type.to_sym][:key]
  end

  def current_status_explanation
    "#{BILL_STATUS[self.current_status.to_sym]} on #{self.current_status_date}".html_safe
  end

  def passed?
    !(self.current_status =~ /^pass/).nil?
  end

  def get_bill_text
    response = HTTParty.get(self.bill_html_link).response
    case response
      when 200
        response.body
      else
        nil
    end
  end

  def bill_text?
    response = HTTParty.get(self.bill_html_link).response
    case response.code
      when "200"
        true
      else
        nil
    end
  end

  def bill_html_link
    "#{bill_link}.html"
  end

  def bill_pdf_link
    "#{bill_link}.pdf"
  end

  def bill_link
    "#{GOVTRACK_URL}/data/us/bills.text/#{self.congress.to_s}/#{self.type_key}/#{self.type_key + self.number.to_s}"
  end

  class << self

    def pull_in_bills(congress = 112, limit = 100)
      GovTrack::Bill.find(congress: congress, order_by: "-current_status_date", limit: limit).each do |bill|
        puts "Pulling in #{bill.title}"
        from_govtrack(bill).save!
      end
    end

    def from_govtrack(bill, add_rolls = false, limit = 500)
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
      b.save
      if legislator = Legislator.where(govtrack_id: bill.sponsor.id).first
        b.sponsor = legislator
      else
        if legislator = Legislator.find_and_build(bill.sponsor.id)
          legislator.save!
          b.sponsor = legislator
        else
          raise "sponsor not found"
        end
      end
      # add rolls ?
      b.save
      if add_rolls
        #GovTrack::Vote.find(related_bill__congress: b.congress, related_bill__bill_type: b.bill_type, related_bill__number: b.number, order_by: "-created").each do |vote|
        GovTrack::Vote.find(related_bill: bill.id, order_by: "-created").each do |vote|
          roll = Roll.from_govtrack(vote)
          roll.add_votes(limit)
          roll.save!
          b.rolls << roll
        end
      end # add rolls
      b
    end # from govtrack

  end # class self

end
