class LegislatorsController < InheritedResources::Base
  has_scope :page, default: 1
  load_and_authorize_resource

  def show
    @legislator = Legislator.find(params[:id])
    @latest_votes = @legislator.latest_votes.page(params[:page])
    show! do |format|
      format.html {    if @legislator.current_role.nil?
                         flash[:notice] = "This legislator has no current role (bad tauber)"
                         redirect_to root_path
                       end}
    end
  end

end
