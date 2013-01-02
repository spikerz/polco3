class Subject
  # currently not used
  include Mongoid::Document
  field :name, :type => String
  index({ name: 1}, {unique: true})

  has_and_belongs_to_many :bills
  #validates_uniqueness_of :name

end
