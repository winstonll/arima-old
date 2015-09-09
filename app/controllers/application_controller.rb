class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  require 'open-uri'
  require 'json'
  protect_from_forgery with: :exception
  helper_method :check_guest

  before_filter :visible_groups, :other_groups
  after_filter :store_location

  def long_poll
    puts "-----------------hello----------"
    respond_to do |format|
      format.js
    end
  end

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

  def check_points_badge
    @points = User.where(id: current_user.id).first.points

    if(user_signed_in?)
      if(@points >= 1000000)
        if(Badge.where(user_id: current_user.id, badge_id: 7).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 7,  date: Date.today.to_s, label: "Mama I made it!")
          acquired.save!
        end
      elsif(@points >= 100000)
        if(Badge.where(user_id: current_user.id, badge_id: 6).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 6, date: Date.today.to_s, label: "The Fort Knox")
          acquired.save!
        end
      elsif(@points >= 10000)
        if(Badge.where(user_id: current_user.id, badge_id: 5).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 5, date: Date.today.to_s, label: "The Fukuzawa")
          acquired.save!
        end
      elsif(@points >= 1000)
        if(Badge.where(user_id: current_user.id, badge_id: 4).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 4, date: Date.today.to_s, label: "The Hidalgo")
          acquired.save!
        end
      elsif(@points >= 100)
        if(Badge.where(user_id: current_user.id, badge_id: 3).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 3, date: Date.today.to_s, label: "The Benjamin")
          acquired.save!
        end
      elsif(@points >= 10)
        if(Badge.where(user_id: current_user.id, badge_id: 2).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 2, date: Date.today.to_s, label: "Sir J Mac D")
          acquired.save!
        end
      else
        return 0
      end
    end
  end

  def check_question_badge
    @num_question = Question.where(user_id: current_user.id).count
    if(user_signed_in?)
      if(@num_question >= 1000)
        if(Badge.where(user_id: current_user.id, badge_id: 11).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 11, date: Date.today.to_s, label: "Confucius Say")
          acquired.save!
        end
      elsif(@num_question >= 100)
        if(Badge.where(user_id: current_user.id, badge_id: 10).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 10, date: Date.today.to_s, label: "Professor")
          acquired.save!
        end
      elsif(@num_question >= 10)
        if(Badge.where(user_id: current_user.id, badge_id: 9).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 9, date: Date.today.to_s, label: "Curious George")
          acquired.save!
        end
      elsif(@num_question >= 1)
        if(Badge.where(user_id: current_user.id, badge_id: 8).first.nil?)
          acquired = Badge.new(user_id: current_user.id, badge_id: 8, date: Date.today.to_s, label: "My Boy")
          acquired.save!
        end
      else
        return 0
      end
    end
  end

  #used to create a larger sample size on localhost
  def create_dummy_users
    @user1 = User.new(first_name: "Number",
                      last_name: "One",
                      birthyear: 1992,
                      gender: "M")
    @user1.build_location(
      province: "Ontario",
      country_code: "CA",
      continent: "North America",
      country: "Canada",
      city: "Toronto",
      latitude: 43.67023,
      longitude: -79.38676)
    @user1.save
    @answer1 = Answer.new(user_id: @user1.id, question_id: 3, value:"programming")
    @answer1.save

    @user2 = User.new(first_name: "Number",
                      last_name: "Two",
                      birthyear: 1993,
                      gender: "F")
    @user2.build_location(
      province: "Pennsylvania",
      country_code: "US",
      continent: "North America",
      country: "United States",
      city: "Downingtown",
      latitude: 43.67023,
      longitude: -79.38676)
    @user2.save
    @answer2 = Answer.new(user_id: @user2.id, question_id: 3, value:"programming")
    @answer2.save

    @user3 = User.new(first_name: "Number",
                      last_name: "Three",
                      birthyear: 1994,
                      gender: "M")
    @user3.build_location(
      province: "Florida",
      country_code: "US",
      continent: "North America",
      country: "United States",
      city: "Port Richey",
      latitude: 43.67023,
      longitude: -79.38676)
    @user3.save
    @answer3 = Answer.new(user_id: @user3.id, question_id: 3, value:"gaming")
    @answer3.save

    @user4 = User.new(first_name: "Number",
                      last_name: "Four",
                      birthyear: 1990,
                      gender: "F")
    @user4.build_location(
      province: "South Dakota",
      country_code: "US",
      continent: "North America",
      country: "United States",
      city: "Sioux Falls",
      latitude: 43.67023,
      longitude: -79.38676)
    @user4.save
    @answer4 = Answer.new(user_id: @user4.id, question_id: 3, value:"soccer")
    @answer4.save

    @user5 = User.new(first_name: "Number",
                      last_name: "Five",
                      birthyear: 1989,
                      gender: "M")
    @user5.build_location(
      province: "Rio de Janeiro",
      country_code: "BR",
      continent: "South America",
      country: "Brazil",
      city: "Rio de Janeiro",
      latitude: 39.67023,
      longitude: -81.38676)
    @user5.save
    @answer5 = Answer.new(user_id: @user5.id, question_id: 3, value:"basketball")
    @answer5.save

    @user6 = User.new(first_name: "Number",
                      last_name: "Six",
                      birthyear: 1988,
                      gender: "F")
    @user6.build_location(
      province: "Ontario",
      country_code: "CA",
      continent: "North America",
      country: "Canada",
      city: "Toronto",
      latitude: 41.67023,
      longitude: -76.38676)
    @user6.save
    @answer6 = Answer.new(user_id: @user6.id, question_id: 3, value:"swimming")
    @answer6.save

    @user7 = User.new(first_name: "Number",
                      last_name: "Seven",
                      birthyear: 1991,
                      gender: "M")
    @user7.build_location(
      province: "Ontario",
      country_code: "CA",
      continent: "North America",
      country: "Canada",
      city: "Toronto",
      latitude: 40.67023,
      longitude: -75.38676)
    @user7.save
    @answer7 = Answer.new(user_id: @user7.id, question_id: 3, value:"studying")
    @answer7.save

    @user8 = User.new(first_name: "Number",
                      last_name: "Eight",
                      birthyear: 1991,
                      gender: "F")
    @user8.build_location(
      province: "Ontario",
      country_code: "CA",
      continent: "North America",
      country: "Canada",
      city: "Toronto",
      latitude: 42.67023,
      longitude: -80.38676)
    @user8.save
    @answer8 = Answer.new(user_id: @user8.id, question_id: 3, value:"soccer")
    @answer8.save
  end

  def check_guest
    ip = request.remote_ip

    #manual way of retrieving geocode data through pointpin online api
    #url = "http://geo.pointp.in/c85a59bd-bcd8-481c-b84b-ad53dabc6f8b/json/82.164.108.48"
    #location_data = JSON.parse(URI.parse(url).read)

    #check if this ip is in the db already
    if (User.find_by(ip_address: ip) == nil)
      #live site
      if(ip != "127.0.0.1")
        #add ip to database
        #@location = Pointpin.locate(ip)
        @result = request.location
        @guest = User.new(ip_address: ip)
        if(@result != nil)
          @user_country = Country.new(@result.data["country_code"])
          @city = request.location.try(:city)
          @province = request.location.try(:state)
        else
          @user_country = Country.new("CA")
          @city = "Toronto"
          @province = "Ontario"
        end

        @guest.build_location(
        #zip_code: @result.data["zipcode"],
        continent: @user_country.subregion,
        province: @province,
        country_code: @user_country.alpha2,
        country: @user_country.name,
        city: @city, #try this code for city @result.data["city"]
        ip_address: ip)

        @guest.save
        cookies[:guest] = { :value => @guest.id, :expires => 1.week.from_now.utc }
      else
        #localhost
        @guest = User.new(ip_address: ip)
        @guest.build_location(
          province: "Ontario",
          country_code: "CA",
          continent: "North America",
          country: "Canada",
          city: "Toronto",
          ip_address: ip)
        @guest.save!

        cookies[:guest] = { :value => @guest.id, :expires => 1.week.from_now.utc }
      end
    else
      @guest = User.find_by(ip_address: ip)

      cookies[:guest] = { :value => @guest.id, :expires => 1.week.from_now.utc }
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

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    categories_path
  end

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
