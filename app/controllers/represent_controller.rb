class RepresentController < ApplicationController

  before_filter :check_geocode

  def check_geocode
    if current_user && !current_user.geocoded?
      flash[:message] = "You should <a href='/users/geocode'>Geocode</a> to participate".html_safe
    end
  end

  def house_bills
    # what are the active house rolls?
    if @user = current_user
      @voted_on_rolls = @user.rolls_voted_on(:house).page(params[:voted_on]).per(5)
      @not_voted_on_rolls = @user.rolls_not_voted_on(:house).page(params[:not_voted_on]).per(10)
    else
      @bills = Bill.introduced_house_bills.page params[:the_rolls]
    end
  end

  def senate_bills
    if @user = current_user
      @voted_on_rolls = @user.rolls_voted_on(:senate).page(params[:voted_on]).per(3)
      @not_voted_on_rolls = @user.rolls_not_voted_on(:senate).page(params[:not_voted_on]).per(5)
    else
      @bills = Bill.introduced_senate_bills.page(params[:the_rolls]).per(10)
    end
  end

  def legislators_districts
    @districts = PolcoGroup.districts.page(params[:page]).per(10)
    @rolls = Roll.house_rolls.page(params[:page]).per(10)
  end

  def states
    #@states = PolcoGroup.states
    @rolls = Roll.senate_rolls.page(params[:page]).per(10)
    @states_with_senators = Kaminari.paginate_array(PolcoGroup.states_with_senators).page(params[:page]).per(10)
  end

  def results
    # this is where the code gets prepared for the chamber results view
    #this page presents one table outlining the bills the user has cast an eballot on.

    # the bills in the table are ordered by most recent at the top
    #for each bill, the table shows the bill's official title,
    # the user's vote, the user's district's tally on that bill,
    # the rep's vote on that bill and the overall bill result.
    #in addition there's a column for the user's comment on that bill.
    # if the user posted a comment on that bill, an expandable arrow appears
    # in that column. when the arrow in that column is selected it opens the user's post's
    # page in new tab (or window) in the browser.
    # future case
    # but can also be ordered by popularity, number of votes, number of comments, number of votes by district members,
    # or searchable.
    if @user = current_user
      if params[:chamber] == "house"
        @chamber = "house"
        @rolls = @user.rolls_voted_on(:house)
      else
        @chamber = "senate"
        @pg_state = @user.state
        @rolls = @user.rolls_voted_on(:senate) # .page(params[:page])
      end
    else
      flash[:notice] = 'You need to be logged in'
      if request.env["HTTP_REFERER"]
        redirect_to :back
      else
        redirect_to :root
      end
      # @bills = Bill.house_bills.page(params[:page])
    end
  end

end
