class ProfilesController < ApplicationController
  include ValidationHelper

  before_filter :authenticate_user!

  layout "application_fluid"

  respond_to :json, :html, :js

  #generates correct referral code
  def show
    user = User.where(username: params[:username]).first
    if(user.nil?)
      redirect_to custom_show_path(:username => current_user.username)
      return
    end

    generate_referral_code(current_user) unless
    (current_user.referral_code.present? && (current_user.referral_code).start_with?(current_user.username))

    @questions_asked_count = Question.where(user_id: user.id).count
    @questions_answered_count = Answer.where(user_id: user.id).count
    #@most_active_category = current_user.most_active_category.keys.first if current_user.most_active_category

    @categories           = Group.all.to_a.uniq { |category_group | category_group.label }
    #@suggested_questions  = Question.suggested_for_user current_user
    #@random_questions     = Question.random_for_user current_user
    #@trending_questions   = Question.trending_for_user current_user
    #@answered_questions   = user.answers.last(5)
    #@asked_questions      = Question.where(user_id: user.id).last(5)

    check_points_badge
    check_question_badge
  end

  def trophy

    respond_to do |format|
      format.js
    end
    
  end

  def image_shared

  end

  def images_questions

  end

  def leaderboard

  end

  def questions_asked

  end

  def questions_answered

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
