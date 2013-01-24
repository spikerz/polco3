class RollPresenter < BasePresenter
  presents :roll

  def vote_region
    if user = current_user
      unless vote = roll.voted_on?(user)
        h.render(partial: "rolls/vote_region", locals: {roll: roll})
      else
        h.content_tag(:div, "You voted #{vote}.")
      end
    else
      "#{link_to('log in', signin_path)} to vote".html_safe
    end
  end

  def vote_tally
    h.content_tag :div do
      h.content_tag(:b, "Vote Results:") + "<br>".html_safe +
      h.content_tag(:p, "Ayes: #{roll.aye}, Nays: #{roll.nay}, No votes: #{roll.nv}, Presents: #{roll.present}")
    end
  end

  def districts_or_states(districts)
    if roll.chamber == "house"
      render(partial: "district_results", locals: {roll: roll, districts: districts}) unless PolcoGroup.districts.empty?
    else
      render(partial: "state_results", locals: {roll: roll, states: PolcoGroup.states})
    end
  end

  def groups(voting_groups)
    render(partial: "group_results", locals: {roll: roll, voting_groups: voting_groups, senators: current_user.senators})
  end

end