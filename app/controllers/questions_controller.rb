class QuestionsController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def show
    #@countries = Location.select(:country_code).distinct.collect { |loc| loc.country_code }

    @question = Question.friendly.find(params[:id])
    @answers = Answer.where(question_id: @question.id).count

    #extracting all of the users that answered this question
    @users_list = Array.new
      Answer.where(question_id: @question.id).find_each do |user|
      @users_list << user.user_id
    end

    #extracting all of the countries that answered the question
    @countries_answered = Array.new
    @users_list.count.times do |user|
      @countries_answered << Location.where(user_id: @users_list[user]).pluck(:country)
    end

    #@countries_answered is an array in an array, extracting the value inside of the inner array and recreating the array.
    @revised_answered = Array.new
    @countries_answered.count.times do |country|
      @revised_answered << @countries_answered[country][0]
    end

    @country_hash = Hash.new
    @revised_answered.count.times do |index|
      if (@country_hash[@revised_answered[index]] == nil)
        @country_hash = {@revised_answered[index] => 1}
      else
        @country_hash = {@revised_answered[index] => @country_hash[@revised_answered[index]] + 1}
      end
    end

    @dropdown_array = Array.new
    @country_hash.each do |key, value|
      @dropdown_array << key + " " + "(" + value.to_s + " answered" + ")"
    end

    check_guest()
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
    #concatenate the answer boxes into one string, checking for empty boxes and removing them
    6.times do |count|
      counter = "answer_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @answerboxes = @answerboxes.to_s + params[counter].to_s << '|'
      end
    end
    #strip the last comma
    @answerboxes = @answerboxes[0...-1]

    @subquestion = Question.create(
      :label => params[:submit_question_name],
      :group_id => params[:group_id],
      :value_type => params[:value_type],
      :options_for_collection => @answerboxes)

    GroupsQuestion.create(group_id: params[:group_id], question_id: @subquestion.id)

    #the logic works, just need to output the error message in the else statement.
      if @subquestion.valid?
        @subquestion.user_id = current_user.id
        redirect_to question_path(@subquestion)
      else
        redirect_to categories_path
        flash[:notice] = "This Question has already been asked!!!"
      end
  end

end
