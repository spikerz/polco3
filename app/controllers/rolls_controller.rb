class RollsController < InheritedResources::Base
  has_scope :page, :default => 1
  load_and_authorize_resource

  def show
    @vote = Vote.new
    @comment = Comment.new
    if u = current_user
      @author = u.nil? ? "" : current_user.name
      @email = u.nil? ? "" : current_user.email
      @voting_groups = u.voting_groups
    end
    @bill = @roll.bill
    show!
  end

  def add_vote
    roll_id = params[:vote][:roll_id]
    user = User.find(params[:vote][:user_id])
    vote = Roll.find(roll_id).vote_on(user, params[:vote][:value])

    respond_to do |format|
      if vote
        format.html { redirect_to roll_path(roll_id), notice: 'Vote was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

end
