class QuestionsController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def show
    @countries = Location.select(:country_code).distinct.collect { |loc| loc.country_name }
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
    @answerboxes = params[:answer_box_1].to_s << ',' << params[:answer_box_2].to_s << ',' << params[:answer_box_3].to_s << ',' << params[:answer_box_4].to_s << ',' << params[:answer_box_5].to_s << ',' << params[:answer_box_6].to_s
    @subquestion = Question.create(
      :label => params[:submit_question_name],
      :group_id => params[:group_id],
      :value_type => params[:value_type],
      :options_for_collection => @answerboxes)


    #the logic works, just need to output the error message in the else statement.
      if @subquestion.valid?
        GroupsQuestion.create!(group_id: params[:group_id], question_id: @subquestion.id)
        @subquestion.user_id = current_user.id
        redirect_to question_path(@subquestion)
      else
        #redirect_to root_path
        redirect_to root_path
        flash[:notice] = "This Question has already been asked!!!"
      end
  end

end
