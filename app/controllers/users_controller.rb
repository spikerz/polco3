class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user?, except: [:index, :geocode, :district, :save_geocode]

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def geocode
    @user = current_user
    address_attempt = @user.get_ip(request.remote_ip)
    # TODO REMOVE!
    # i don't like this but it is a good way to get a default address
    address_attempt = [38.7909, -77.0947] if address_attempt.all? { |a| a == 0 }
    @coords = User.build_coords_simple(address_attempt)
    district = User.get_district_from_coords(address_attempt).first
    @district, @state = district.district, district.us_state
    @lat = params[:lat] || "19.71844"
    @lon = params[:lon] || "-155.095228"
    @zoom = params[:zoom] || "10"
    # read in the map data information
    json = JSON(File.read("#{Rails.root}/public/district_data/#{@district}.json"))
    # ["name", "extents", "centroid", "coords"]
    #gon.file_name = json["name"]
    gon.coords = json["coords"]
    gon.extents = json["extents"]
    gon.centroid = json["centroid"]
  end

  def district
    user = current_user
    case params[:commit]
      when "Yes"
        coords= Geocoder.coordinates(params[:location])
        districts = User.get_district_from_coords(coords)
        flash[:method] = :ip_lookup
      when "Submit Address"
        coords = Geocoder.coordinates(user.build_address(params))
        districts = User.get_district_from_coords(coords)
        flash[:method] = "Successful address lookup"
      when "Submit Zip Code"
        districts = User.get_districts_by_zipcode(params[:zip_code])
        flash[:method] = "Successful zip code lookup"
      else
        districts = nil
    end
    if districts.nil?
      flash[:notice] = "No addresses found, please refine your answer or try a different method."
      redirect_to users_geocode_path
    elsif districts.count > 1 # then we need to pick a district
      flash[:notice] = "Multiple districts found for #{params[:zip_code]}, please enter your address or a zip+4"
      redirect_to users_geocode_path
    else
      district = districts.first
      @district, @state = district.district, district.us_state
      members = self.get_members(district.members)
      @senior_senator = members[:senior_senator]
      @junior_senator = members[:junior_senator]
      @representative = members[:representative]
      #@coords = User.build_coords(coords, @district)
      json = JSON(File.read("#{Rails.root}/public/district_data/#{@district}.json"))
      gon.coords = json["coords"]
      gon.extents = json["extents"]
      gon.centroid = json["centroid"]
    end
  end

  def save_geocode
    @user = current_user
    # TODO remove old state and district polco_groups
    #@user.custom_groups.where(type: :state).delete_all
    #@user.custom_groups.where(type: :district).delete_all
    # now add exactly two custom_groups
    # how do these params get loaded -- the form . . .
    @senior_senator = Legislator.where(:_id => params[:senior_senator]).first
    @junior_senator = Legislator.where(:_id => params[:junior_senator]).first
    @representative = Legislator.where(:_id => params[:representative]).first
    @user.add_members(@junior_senator, @senior_senator, @representative, params[:district], params[:us_state])
    # TODO save the zip code + 4 too!
    # look up bills sponsored by member
  end

end
