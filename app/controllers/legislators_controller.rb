class LegislatorsController < InheritedResources::Base
  has_scope :page, default: 1
  load_and_authorize_resource

  def show
    super
    @latest_votes = @legislator.latest_votes.page(params[:page])
  end

end
