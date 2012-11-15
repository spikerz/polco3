module ApplicationHelper

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.html_safe) }
    @show_title = show_title
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

end
