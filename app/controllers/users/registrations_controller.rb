class Users::RegistrationsController < Devise::RegistrationsController

  def create
    check_guest()

    if !params[:trick_user].nil?

      if params[:generated_username].nil? && params[:user][:username].empty?
        redirect_to :back
        return false
      end

      @user = User.where(id: cookies[:guest]).first
      @user.first_name = nil
      @user.password = '123456'
      params[:generated_username].nil?  || params[:generated_username].empty? ? @user.username = params[:user][:username] : @user.username = params[:generated_username]
      @user.save

      @question = Question.where(id: cookies[:q]).first
      if @question.shared_image
        @tag = Tag.where(question_id: @question.id, label: cookies[:answer]).first
        if @tag.nil?
          @tag = Tag.new(question_id: @question.id, label: cookies[:answer])
          @tag.counter = 1
          @tag.save!
        else
          @tag.counter = @tag.counter + 1
          @tag.save!
        end

        @opinion = Opinion.new(question_id: @question.id, tag_id: @tag.id, user_id: cookies[:guest])
        @opinion.save!
      else
        @question.options_for_collection = @question.options_for_collection + "|#{cookies[:answer]}"
        @question.save
        @answer = Answer.new(value: cookies[:answer], question_id: cookies[:q], user_id: cookies[:guest])
        @answer.save
      end

      @winston = User.new(email: "winston@arima.io")
      UserMailer.signup_admin(@winston, @user).deliver!
      sign_in(:user, @user)

      if(Badge.where(user_id: current_user.id, badge_id: 1).first.nil?)
        badge = Badge.new(user_id: current_user.id, badge_id: 1, date: Date.today.to_s, label: "Starter Badge")
        badge.save!
      end

      cookies[:signup] = nil
      cookies[:answer] = nil
      cookies[:q] = nil
      redirect_to :back
      return true
    end

    @user = User.where(id: cookies[:guest]).first
    @user.first_name = nil
    @user.password = user_params["password"]
    #@user.email = user_params["email"]
    @user.username = user_params["username"]

    if !user_params["gender"].nil? then @user.gender = user_params["gender"] end
    if !user_params["birthyear"].nil? then @user.birthyear = user_params["birthyear"] end

    @location = @user.location
    if !params[:user]["location_attributes"].nil? then @location.country_code = params[:user]["location_attributes"]["country"] end
    if !params[:user]["location_attributes"].nil? then @location.country = Country.new(params[:user]["location_attributes"]["country"]).name end
    if !params[:user]["location_attributes"].nil? then @location.city = params[:user]["location_attributes"]["city"].strip.downcase.capitalize end
    @user.save
    @location.save

    #if(!@user.errors["email"].empty?)
    #  flash[:notice] = "Email " + @user.errors['email'].first
    #end

    if(!@user.errors["username"].empty?)
      if(flash[:notice].nil?)
        flash[:notice] = "Username " + @user.errors['username'].first
      else
        flash[:notice] = flash[:notice] + "/Username " + @user.errors['username'].first
      end
    end

    if(!(user_params['password'].length > 5 && user_params['password'].length < 21))
      @user.errors.add(:password, "length must be between 6-20 characters")
      if(flash[:notice].nil?)
        flash[:notice] = "Password " + @user.errors['password'].first
      else
        flash[:notice] = flash[:notice] + "/Password " + @user.errors['password'].first
      end
    end

    if(@user.errors['password'].empty?)
      respond_to do |format|
        if @user.save

          # After signup is submitted, check if the user was referred
          reward_referral(params[:referral]) if params[:referral].present?

          #UserMailer.signup_email(@user).deliver!
          @winston = User.new(email: "winston@arima.io")
          UserMailer.signup_admin(@winston, @user).deliver!
          sign_in(:user, @user)

          if(Badge.where(user_id: current_user.id, badge_id: 1).first.nil?)
            badge = Badge.new(user_id: current_user.id, badge_id: 1, date: Date.today.to_s, label: "Starter Badge")
            badge.save!
          end

          if (cookies[:signup] != nil && cookies[:signup] == "1")
            @question = Question.where(id: cookies[:q]).first
            if(!Question.where(id: cookies[:q]).first.options_for_collection.split('|').include?(cookies[:answer]))
              answer = Answer.new(user_id: cookies[:guest], question_id: cookies[:q], value: cookies[:answer])
              question = Question.where(id: cookies[:q]).first
              question.options_for_collection = question.options_for_collection + "|" + cookies[:answer].capitalize
              question.save!
              answer.save!
            end
            cookies[:signup] = nil
            cookies[:answer] = nil
            cookies[:q] = nil
            cookies[:answer] = nil

            format.html { redirect_to question_path(@question) }
            format.json { render json: @user, status: :created, location: @user }
          else
            format.html { redirect_to feed_path }
            format.json { render json: @user, status: :created, location: @user }
          end
        else
          format.html { redirect_to :back }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to :back
    end
  end

  private
    def user_params
      params.require(:user).permit(
        #:email,
        :password,
        :username,
        :gender,
        :birthyear,
        location_attributes: [
          :city,
          :country
        ])
    end

  def reward_referral(user_referral_code)
    @referral_code = user_referral_code
    @referring_user = User.find_by_referral_code(@referral_code)
    @referring_user.points += 5
    @referring_user.save!
    #UserMailer.referred_user_email(@referring_user, @user).deliver!
    return
  end
end
