class PolcoGroupsController < InheritedResources::Base
  has_scope :page, default: 1
  helper_method :sort_column, :sort_direction
  load_and_authorize_resource

  def add_custom_group
    @polco_group = PolcoGroup.new
  end

  def index
    if params[:direction].to_s == "asc"
      @polco_groups = PolcoGroup.asc(params[:sort].downcase.to_sym).all.page(params[:page]).per(10)
    elsif params[:direction].to_s == "desc"
      @polco_groups = PolcoGroup.desc(params[:sort].downcase.to_sym).all.page(params[:page]).per(10)
    else
      @polco_groups = PolcoGroup.all.page(params[:page]).per(20)
    end
  end

  def show
    @comment = Comment.new
    @author = current_user.nil? ? "" : current_user.name
    @email = current_user.nil? ? "" : current_user.email
    show!
  end

  private

  def sort_column
    PolcoGroup.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
