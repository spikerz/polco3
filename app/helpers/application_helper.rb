module ApplicationHelper

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.html_safe) }
    @show_title = show_title
  end

end
