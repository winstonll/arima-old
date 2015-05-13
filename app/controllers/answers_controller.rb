class AnswersController < ApplicationController

  #skip_before_filter :verify_authenticity_token, :only => :create
  #before_filter :authenticate_user!, except: [:intro_question, :show, :create, :show_image]
  include DetermineUserAndUnits

  layout "application_fluid"

  respond_to :json, :html, :js

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
    #@user.gender = gender
    session[:guest].gender = gender

    if( 1900 < year && year < Time.now.year && session[:guest].gender != nil)
      session[:guest].birthyear = year
      session[:guest].save
      redirect_to :back
    else
      flash[:notice] = "Year of birth and/or gender was invalid!"
      redirect_to :back
    end
  end

  def create
    @question = Question.friendly.find(params[:question_id])

    #create answer if user hasn't already submitted one for this question
    if (session[:guest] && @answer = @question.answers.where(user: session[:guest]).first).nil?
      @answer = @question.answers.build(params[:answer].permit(:value))
      @answer.user = session[:guest]

      if @answer.save
        if session[:guest].share_modal_state != "hide"
          redirect_to question_path(@question), flash: { share_answer_modal: true }
        else
          redirect_to question_path(@question)
        end
      end
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
