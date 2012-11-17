class LegislatorsController < InheritedResources::Base
  has_scope :page, default: 1

  def show
    super
    @latest_votes = @legislator.latest_votes.page(params[:page])
  end
end
