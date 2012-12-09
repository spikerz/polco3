class HomeController < ApplicationController

  before_filter :check_geocode

  def check_geocode
    if current_user && !current_user.geocoded?
      flash[:message] = "You should <a href='/users/geocode'>Geocode</a> to participate".html_safe
    end
  end

  def index

  end
end
