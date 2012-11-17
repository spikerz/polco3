class RollPresenter < BasePresenter
  presents :roll

  def vote_region
    if user = current_user
      unless vote = roll.voted_on?(user)
        h.render(partial: "vote_region", locals: {roll: roll})
      else
        h.content_tag(:div, "You voted #{vote} on this roll already.")
      end
    else
      "#{link_to('log in', signin_path)} to vote".html_safe
    end
  end

end