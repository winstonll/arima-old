class ProfilesController < ApplicationController
  include ValidationHelper

  layout "application_fluid"

  respond_to :json, :html, :js

  #generates correct referral code
  def show

    @user_profile = User.where(username: params[:username]).first

    if(@user_profile.nil?)
      redirect_to custom_show_path(:username => current_user.username)
      return
    end

    #generate_referral_code(current_user) unless
    #(current_user.referral_code.present? && (current_user.referral_code).start_with?(current_user.username))


    @questions_and_images_asked_count = Question.where(user_id: @user_profile.id).count

    @questions_images_asked_count = Question.where(user_id: @user_profile.id, shared_image: true).count

    @questions_asked_count = Question.where(user_id: @user_profile.id, shared_image: false).count

    @questions_answered_count = Answer.where(user_id: @user_profile.id).count


    #@most_active_category = current_user.most_active_category.keys.first if current_user.most_active_category

    @categories           = Group.all.to_a.uniq { |category_group | category_group.label }
    #@suggested_questions  = Question.suggested_for_user current_user
    #@random_questions     = Question.random_for_user current_user
    #@trending_questions   = Question.trending_for_user current_user
    #@answered_questions   = user.answers.last(5)
    #@asked_questions      = Question.where(user_id: user.id).last(5)
    if (user_signed_in?)
      check_points_badge
      check_question_badge
    end
  end

  def trophy
    respond_to do |format|
      format.js
    end
  end

  def image_shared

    @all = Question.where(user_id: params[:username], shared_image: true)

    respond_to do |format|
      format.js
    end
  end

  def images_questions

    @all = Question.where(user_id: params[:username])

    respond_to do |format|
      format.js
    end
  end

  def leaderboard
    @countries = Location.select(:country_code).distinct.collect { |loc| loc.country_code }
    @ranked_registered_users = User.order("points DESC").limit(50)
    @user_rank =  user_signed_in? ? User.where(id: current_user.id).first.rank : "?"
    @user = current_user
    respond_to do |format|
      format.js
    end
  end

  def questions_asked

    @all = Question.where(user_id: params[:username], shared_image: false)

    respond_to do |format|
      format.js
    end
  end

  def questions_answered

    @all = Question.joins(:answers).where("answers.user_id = #{params[:username]}")

    respond_to do |format|
      format.js
    end
  end

  def edit
    @profile = current_user
  end

  def badge
    @badge_label = params[:badgeLabel]
    @badge_id = params[:badgeId].to_i
    #respond_with(@test_user)
    respond_to do |format|
      format.js
    end
  end

  def update
    # Validate before attempting update
    if !(valid_alphanum?(
      params[:user][:username]
    ) or valid_email?(
      params[:user][:email])
    ) then
      redirect_to(request.referer)
     #flash[:notice] = "Letters and numbers only!"
    else
      params[:user][:location_attributes][:city].downcase!.capitalize!              if params[:user][:location_attributes][:city].present?

      # It's all good, update
      current_user.update(params[:user].permit(
        :avatar,
        :first_name,
        :last_name,
        :gender,
        :email,
        :username,
        :birthyear,
        :measurement_unit,
        location_attributes: [
          :id,
          :city,
          :country_code
        ]
      ))
     end
     redirect_to(request.referer)
     flash[:notice] = 'You\'ve sucessfully updated your profile!' and return
  end


  protected

  #Generates referral code "username-hexcode"
  def generate_referral_code user
    user.referral_code = "#{user.username}-#{SecureRandom.hex[0,5]}"
    user.save!
    user.referral_code
  end

  def questions
    Question.where("user_id = #{current_user.id}").order("updated_at desc")
  end
end
