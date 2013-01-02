class Role
  include Mongoid::Document

  field :congress_numbers, type: Array
  field :current, type: Boolean
  field :description, type: String
  field :district, type: String
  field :enddate, type: Date
  field :id, type: String
  field :party, type: String
  field :resource_uri, type: String
  field :role_type, type: Integer
  field :role_type_label, type: String
  field :senator_class, type: Integer
  field :startdate, type: Date
  field :state, type: String
  field :title, type: String
  field :title_long, type: String
  field :website, type: String

  ROLL_TYPES = {1 => "President", 2=> "Representative", 3=>"Senator"}
  SENATOR_CLASS = {0 => 'none', 1 => 'Class 1', 2 => 'Class 2', 3 => 'Class 3'}

  embedded_in :elected_member, class_name: "Legislator", inverse_of: :current_role
  embedded_in :legislator

  def roll_type_label
    ROLL_TYPES[self.roll_type]
  end

  def senator_class_label
    SENATOR_CLASS[self.senator_class]
  end

  class << self

    def find_role_type(k)
      case k
        when "senator"
          3
        when "president"
          1
        else
          2
      end
    end

    def find_senator_class(k)
      case k
        when "class1"
          1
        when "class2"
          2
        when "class3"
          3
        else
          0
      end
    end

    def from_govtrack(gt_o)
      m_o = Role.new
      # role_type
      m_o.role_type = find_role_type(gt_o.role_type)
      # senator_class
      m_o.senator_class = find_senator_class(gt_o.senator_class)
      m_o.congress_numbers = gt_o.congress_numbers
      m_o.current = gt_o.current
      m_o.description = gt_o.description
      m_o.district = gt_o.district
      m_o.enddate = gt_o.enddate
      m_o.id = gt_o.id
      m_o.party = gt_o.party
      m_o.resource_uri = gt_o.resource_uri
      m_o.role_type_label = gt_o.role_type_label
      m_o.startdate = gt_o.startdate
      m_o.state = gt_o.state
      m_o.title = gt_o.title
      m_o.title_long = gt_o.title_long
      m_o.website = gt_o.website
      m_o
    end

  end

end
