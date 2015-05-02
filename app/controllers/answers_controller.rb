class AnswersController < ApplicationController

  #skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :authenticate_user!, except: [:intro_question, :show, :create, :show_image]
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

  def create
    @question = Question.friendly.find(params[:question_id])

    #create answer if user hasn't already submitted one for this question
    if (@user && @answer = @question.answers.where(user: @user).first).nil?
      @answer = @question.answers.build(params[:answer].permit(:value))
      @answer.user = @user

      if @answer.save
        if @user.share_modal_state != "hide"
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
