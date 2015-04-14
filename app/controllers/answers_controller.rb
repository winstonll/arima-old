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

      @answer.shared_twitter = false
      @answer.shared_facebook = false
      @answer.shared_pinterest = false

      if @answer.save
        redirect_to question_path(@question)
      end

    end

    # if params[:answer].has_key? :from_modal
    # end
  end

  def intro_question
    @user = session[:intro_user]
    @group = Group.find(params[:group_id])
    @question = @group.questions.all.sample(1).first
    @answer = @question.answers.build

    render "intro_new", layout: false
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

  # thumbnail
  def show_image
    # TODO: check for facebook user agent
    chart = Answer.find(params[:answer_id]).generate_image
    send_data chart.to_blob, :type => 'image/png', :disposition => 'inline'
  end
end
