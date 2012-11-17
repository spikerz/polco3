class RollsController < InheritedResources::Base
  has_scope :page, :default => 1

  def show
    @vote = Vote.new
    super
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
