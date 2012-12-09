class PolcoGroupsController < InheritedResources::Base
  has_scope :page, default: 1
  load_and_authorize_resource

  def add_custom_group
    @polco_group = PolcoGroup.new
  end
end
