class BillPresenter < BasePresenter
  presents :bill

  def bill_title
    h.content_tag(:div, bill.long_title, id: 'bill_title')
  end

  def bill_description
    h.content_tag(:div, bill.long_title) +
    h.content_tag(:div, h.content_tag(:h3, "Status") + bill.status_description)
  end

  def bill_sponsor
    h.content_tag(:div, "Sponsored by #{h.link_to(bill.sponsor.full_name, legislator_path(bill.sponsor.id))}".html_safe) if bill.sponsor
  end

  def summary
    content_tag(:div, bill.summary) unless bill.summary.strip.blank?
  end

  def rolls
    render partial: "rolls", locals: {rolls: bill.rolls} if bill.rolls.size > 0
  end

end
