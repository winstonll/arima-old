class ProfilesController < ApplicationController
  include ValidationHelper

  before_filter :authenticate_user!

  layout "application_fluid"

  respond_to :json, :html

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

  #generates correct referral code
  def show
    generate_referral_code(current_user) unless
    (current_user.referral_code.present? && (current_user.referral_code).start_with?(current_user.username))

    @points_count = current_user.points || 0
    @questions_count = current_user.questions.count
    @most_active_category = current_user.most_active_category.keys.first if current_user.most_active_category

    @categories           = Group.all.to_a.uniq { |category_group | category_group.label }
    @suggested_questions  = Question.suggested_for_user current_user
    @random_questions     = Question.random_for_user current_user
    @trending_questions   = Question.trending_for_user current_user
    @answered_questions   = current_user.answers.order("updated_at desc")
    @asked_questions      = self.questions
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
