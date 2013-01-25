class PolcoGroupsController < InheritedResources::Base
  has_scope :page, default: 1
  helper_method :sort_column, :sort_direction
  #respond_to :js, only: [:join_group, :follow_group]
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

  def join_group
    pg = PolcoGroup.find(params[:join_group][:polco_group_id])
    user = User.find(params[:join_group][:user_id])
    pg.add_member(user)
    @members = pg.members
  end

  def follow_group
    pg = PolcoGroup.find(params[:follow_group][:polco_group_id])
    user = User.find(params[:follow_group][:user_id])
    pg.add_follower(user)
    @followers = pg.followers
  end

  def create
    @polco_group = PolcoGroup.new(params[:polco_group])
    @polco_group.owner = current_user
    if @polco_group.save
      if params[:polco_group][:type] == 'custom' && params[:add_custom_group]
        # then a user is creating a new custom group
        @polco_group.add_member(current_user)
      end
      redirect_to @polco_group, notice: "Custom Group \"#{@polco_group.name}\" was successfully completed"
    else
      render :new
    end
  end

  def show
    @polco_group = PolcoGroup.find(params[:id])
    @comment = Comment.new
    @user = current_user
    @author = @user.nil? ? "" : @user.name
    @email = @user.nil? ? "" : @user.email
    @rolls =  @polco_group.votes.map{|v| v.roll}.uniq
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
