class LeaderboardsController < ApplicationController
	include ValidationHelper

	layout "application_fluid"

	def index
    # Determine all locations for filtering
    @countries = Location.select(:country_code).distinct.collect { |loc| loc.country_code }

    # Use as a base for location filtering and user rank
    @registered_users = Array.new

    User.find_each do |user|
      @registered_users << user.points
    end

    @registered_users = qsort(@registered_users)

    rank = @registered_users.length - @registered_users.find_index { |w| w == 2 }

    #if @countries.find { |c| c == params[:country_type] }
    #  @ranked_registered_users = @registered_users.where('locations.country_code' => params[:country_type])[0...50]
    #else
      @ranked_registered_users = User.order("points DESC").limit(50)
    #end

	  @user_rank =  user_signed_in? ? rank : "?"
	  @user = current_user

	  #respond_to do |format|
	  #  format.html
	  #  format.js
	  #end
	end
end
