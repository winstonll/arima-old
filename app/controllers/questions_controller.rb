class QuestionsController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def show
    #@countries = Location.select(:country_code).distinct.collect { |loc| loc.country_code }

    @question = Question.friendly.find(params[:id])
    @answers = Answer.where(question: @question).count


    #extracting all of the users that answered this question
    @users_list = Array.new
    Answer.where(question: @question).find_each do |answer|
      @users_list << answer.user_id
    end
    
    @countries_answered = @users_list.flat_map do |user|
      Location.where(user_id: user).pluck(:country)
    end

    #update_nil_country()
    #create_dummy_users()
    if(@user == nil)
      check_guest()
    end

    if @user
      @user_country = Location.where(user_id: @user.id).first
      @dropdown_array = [@user_country.country]

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

  def stats
    q = Question.find(params[:id])
    result = {
      name: q.label,
      answers: q.grouped_answers
    }

    render json: result
  end

  def create

    if(@user == nil)
      check_guest()
    end

    # Concatenate the answer boxes into one string, checking for empty boxes and removing them
    13.times do |count|
      counter = "answer_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @answerboxes = @answerboxes.to_s + params[counter].to_s << '|'
      end
    end

    # Strip the last comma
    @answerboxes = @answerboxes[0...-1]

    @subquestion = Question.create(
      :label => params[:submit_question_name],
      :group_id => params[:group_id],
      :user_id => @user.id,
      :value_type => params[:value_type],
      :options_for_collection => @answerboxes)

    GroupsQuestion.create(group_id: params[:group_id], question_id: @subquestion.id)

    # The logic works, just need to output the error message in the else statement.
    if @subquestion.valid?
      redirect_to question_path(@subquestion)
    else
      redirect_to categories_path
      flash[:notice] = "This Question has already been asked"
    end
  end

end
