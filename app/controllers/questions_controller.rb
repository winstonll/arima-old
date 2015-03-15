class QuestionsController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def show
    @question = Question.friendly.find(params[:id])
    if @user
      @answer = @question.answers.where(user_id: @user.id).first
      if @answer.nil?
        @user_submitted_answer = false
        @answer = @question.answers.build(user: @user)
      else
        @user_submitted_answer = true
      end
    end
  end

  def new
    @subquestion = Question.new
  end

  def create
    @subquestion = Question.create!(
      :label => params[:submit_question_name],
      :group_id => params[:group_id],
      :value_type => params[:value_type],
      :options_for_collection => params[:answer_box_1])

    GroupsQuestion.create!(group_id: params[:group_id], question_id: @subquestion.id)

    @subquestion.user_id = current_user.id

    if @subquestion.save
      redirect_to question_path(@subquestion)
    end
  end

end
