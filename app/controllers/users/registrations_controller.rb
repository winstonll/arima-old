class Users::RegistrationsController < Devise::RegistrationsController

  def create

    @user = User.new(user_params)
    #@user.build_location(
    #  country_code: params["location"]["country_code"].strip,
    #  city: params["location"]["city"].strip.downcase.capitalize
    #)

    respond_to do |format|
      if @user.save

        # After signup is submitted, check if the user was referred
        reward_referral(params[:referral]) if params[:referral].present?

        #UserMailer.signup_email(@user).deliver!
        sign_in(:user, @user)
        format.html { redirect_to categories_path }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :username)
    end

  def reward_referral(user_referral_code)
    @referral_code = user_referral_code
    @referring_user = User.find_by_referral_code(@referral_code)
    @referring_user.points += 5
    @referring_user.save!
    UserMailer.referred_user_email(@referring_user, @user).deliver!
    return
  end
end
