module ApplicationHelper

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.html_safe) }
    @show_title = show_title
  end

  def admin?
    true if current_user && current_user.admin?
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def act(action)
    @selected == action ? 'active' : ''
  end

end
