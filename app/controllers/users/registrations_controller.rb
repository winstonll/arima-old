class Users::RegistrationsController < Devise::RegistrationsController

  def create

    check_guest()
    @user = session[:guest]
    @user.first_name = nil
    @user.password = user_params["password"]
    @user.email = user_params["email"]
    @user.username = user_params["username"]
    @user.save

    #@user.build_location(
    #  country_code: params["location"]["country_code"].strip,
    #  city: params["location"]["city"].strip.downcase.capitalize
    #)

    if(!@user.errors["email"].empty?)
      flash[:notice] = "Email " + @user.errors['email'].first
    end

    if(!@user.errors["username"].empty?)
      if(flash[:notice].nil?)
        flash[:notice] = "Username " + @user.errors['username'].first
      else
        flash[:notice] = flash[:notice] + "/Username " + @user.errors['username'].first
      end
    end

    if(!@user.errors["password"].empty?)
      if(flash[:notice].nil?)
        flash[:notice] = "Password " + @user.errors['password'].first
      else
        flash[:notice] = flash[:notice] + "/Password " + @user.errors['password'].first
      end
    end

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
