class SubjectsController < InheritedResources::Base
  has_scope :page, :default => 1
  load_and_authorize_resource
end
