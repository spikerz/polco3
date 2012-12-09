class VotesController < InheritedResources::Base
  has_scope :page, default: 1
  load_and_authorize_resource

  def index
    @votes = Vote.where(user: current_user).page
  end

end
