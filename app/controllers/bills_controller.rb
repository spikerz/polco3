class BillsController < InheritedResources::Base
  load_and_authorize_resource
  has_scope :page, :default => 1

end
