class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :check_guest

  before_filter :visible_groups, :other_groups
  after_filter :store_location

  def visible_groups
    @visible_groups ||= Group.visible_groups
  end

  def other_groups
    @other_groups ||= Group.other_groups(visible_groups)
  end

  def update_nil_country
    @location_update = Location.where(country: nil)
    @location_update.each do |index|
      @extracted_country = Country.new(index.country_code).name
      Location.update(index.id, :country => @extracted_country)
    end
  end

  def check_guest
    #ip = request.remote_ip
    @result = request.location
    if (@result)
      ip = @result.data["ip"]
    end
    #check if this ip is in the db already
    if (User.find_by(ip_address: ip) == nil)
      #live site
      if(ip != "127.0.0.1")
        #add ip to database
        @user = User.new(ip_address: ip)
        @user_country = Country.new(@result.data["country_code"])

        @user.build_location(
        #zip_code: @result.data["zipcode"],
        continent: @user_country.subregion,
        province: request.location.try(:state),
        country_code: @result.data["country_code"],
        country: Country.new(@result.data["country_code"]).name,
        city: request.location.try(:city), #try this code for city @result.data["city"]
        ip_address: ip)

        @user.save
        sign_in(:user, @user)
      #localhost
      else
        @user = User.new(ip_address: ip)
        @user.build_location(
        province: "Ontario",
        country_code: "CA",
        continent: "North America",
        country: "Canada",
        city: "Toronto",
        ip_address: ip)
        @user.save
        sign_in(:user, @user)
      end
    else
      @user = User.find_by(ip_address: ip)
      sign_in(:user, @user)
    end
  end

  protected

  def after_sign_in_path_for(resource)
    # return the path based on resource
    # root_path
    session[:previous_url] || root_path
  end

  def after_sign_out_path_for(resource)
    # return the path based on resource
    # session[:previous_url] || root_path
    root_path
  end

  private

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
          session[:previous_url] = request.fullpath
    end
  end

  def resolve_layout
    case action_name
    when "terms", "privacy", "credits", "about", "faq", "contact"
      "application"
    else
      "application_fluid"
    end
  end
end
