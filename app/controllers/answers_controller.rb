class AnswersController < ApplicationController

  #skip_before_filter :verify_authenticity_token, :only => :create
  #before_filter :authenticate_user!, except: [:intro_question, :show, :create, :show_image]
  include DetermineUserAndUnits

  layout "application_fluid"

  respond_to :json, :html, :js
  skip_before_filter :verify_authenticity_token, :only => :create

  def show
    @answer = Answer.find(params[:id])
    if request.path != answer_path(@answer)
      redirect_to answer_path(@answer), status: :moved_permanently
    end
    @image = "#{request.protocol}#{request.host_with_port}#{answer_thumb_path(params[:id])}"
    @title = "Arima Report"
    @description = @answer.description
    @url = answer_url(@answer.id)

    if request.xhr?
      render partial: 'questions/answer_report', locals: {answer: @answer} , :layout => false
    end
  end

  def gender
    year = params[:age_text].to_i
    gender = params[:gender_id].to_i == 1 ? "M" : "F"
    @guest = User.where(id: cookies[:guest]).first
    user_signed_in? ? current_user.gender = gender : @guest.gender = gender
    #session[:guest].gender = gender

    if(user_signed_in?)
      if( 1900 < year && year < Time.now.year && current_user.gender != nil)
        current_user.birthyear = year
        current_user.save
        redirect_to :back
      else
        flash[:notice] = "Year of birth and/or gender was invalid!"
        redirect_to :back
      end
    else
      if( 1900 < year && year < Time.now.year && @guest.gender != nil)
        @guest.birthyear = year
        @guest.save
        redirect_to :back
      else
        flash[:notice] = "Year of birth and/or gender was invalid!"
        redirect_to :back
      end
    end
  end

  def create
    @question = Question.friendly.find(params[:question_id])

    #add new answer
    if params[:answer][:options_for_collection] != ""
      if (!user_signed_in?)
        cookies[:signup] = 1
        cookies[:q] = @question.id
        cookies[:answer] = params[:answer][:options_for_collection]
        redirect_to new_user_registration_path
        return
      end

      answer_values = @question.options_for_collection
      a = (0 ... answer_values.length).find_all { |i| answer_values[i,1] == '|' }

      if @question.options_for_collection.include? params[:answer][:options_for_collection]
        redirect_to @question
        flash[:notice] = "This answer value already exists!"
        return
      else
        @question.options_for_collection = @question.options_for_collection + "|" + params["answer"]["options_for_collection"].capitalize
        @question.save
      end

      if @question.save
        @answer = Answer.new(user_id: current_user.id, question_id: @question.id, value: params[:answer][:options_for_collection].capitalize)
        @answer.save!
        redirect_to @question
        return
      else
        redirect_to :back
        return
      end
    end

    #create answer if user hasn't already submitted one for this question
    if (!cookies[:guest].nil? && @answer = @question.answers.where(user: User.where(id: cookies[:guest])).first).nil?
      if(user_signed_in?)
        @answer = @question.answers.build(params[:answer].permit(:value))
        @answer.user = current_user

        if @answer.save
          current_user.points = current_user.points + 1
          current_user.save
          if(user_signed_in?)
            check_points_badge
          end
          if(@question.user_id != nil)
            q_owner = User.where(id: @question.user_id)
            if((Answer.where(question_id: @question.id).length % 10) == 0 && !q_owner.nil?)
              q_owner.points = q_owner.points + 1
              q_owner.save
            end
          end

          if current_user.share_modal_state != "hide"
            redirect_to question_path(@question), flash: { share_answer_modal: true }
            return
          else
            redirect_to question_path(@question)
            return
          end
        end
      else
        @answer = @question.answers.build(params[:answer].permit(:value))
        @guest = User.where(id: cookies[:guest]).first
        @answer.user = @guest

        if @answer.save
          if @guest.share_modal_state != "hide"
            redirect_to question_path(@question), flash: { share_answer_modal: true }
            return
          else
            redirect_to question_path(@question)
            return
          end
        end
      end
    end
    #refresh page if submitted with nothing
    if params[:answer][:options_for_collection] == ""
      redirect_to :back
    end
  end

  def share
    answer = Answer.where(id: params[:ans_id]).first
    ans_user = answer.user
    if answer["shared_"+ params[:share_type]] # Already shared with that type of social media
      flash[:notice] = "Thanks for sharing again with #{params[:share_type]}"
      flash.discard
      @answer = answer
    else # hasn't been shared yet
      ans_user.points += 5
      answer["shared_"+ params[:share_type]] = true
      flash[:notice] = "Successfully shared with #{params[:share_type]}, +5 points!"
      flash.discard
      answer.save
      ans_user.save
      @answer = answer
    end
  end
end
