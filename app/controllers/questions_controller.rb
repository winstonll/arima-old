class QuestionsController < ApplicationController
  include DetermineUserAndUnits
  layout "application_fluid"

  # Show method - called when question page is rendered
  def show
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

    @country_hash = @countries_answered.inject(Hash.new(0)) { |country, count| country[count] += 1 ; country }


    # @country_hash = Hash.new
    # @countries_answered.each do |country, count|
    #  if (@country_hash[country] == nil)
    #     @country_hash = {country => count.length}
    #   else
    #     @country_hash = {country => @country_hash[country] + 1}
    #   end
    #  end

    # @dropdown_array = Array.new
    # @country_hash.each do |key, value|
    #   if (key != nil && value != nil)
    #     @dropdown_array << key + " " + "(" + value.to_s + " answered" + ")"
    #   end
    # end

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

  # Gets the question's answer stats for reports
  def stats
    q = Question.find(params[:id])
    result = {
      name: q.label,
      answers: q.grouped_answers
    }
    render json: result
  end

  # Upvotes the question
  def upvote
    @question = Question.friendly.find(params[:id])

    # Check to see if the question has already been voted on
    @existing_vote = Vote.where(:question_id => params[:id]).where(:user_id => @user.id)

    if (@existing_vote.empty?)
      # Update the question table votecount value
      @question.increment(:votecount)
      @question.save!

      # Update the Votes table with the new vote
      Vote.create(
        :user_id => @user.id,
        :question_id => params[:id],
        :vote_type => "upvote")
    elsif (@existing_vote.pluck(:vote_type)[0] == "downvote")
      # Change the question from downvote to upvote
      @existing_vote.first.update_attributes(vote_type: "upvote")

      # Increment counter by 2 to counter the downvote
      @question.increment(:votecount, 2)
      @question.save!
    end

    respond_to do |format|
      format.js
    end
  end

  # Downvotes the question
  def downvote
    @question = Question.friendly.find(params[:id])

    # Check to see if the question has already been voted on
    @existing_vote = Vote.where(:question_id => params[:id]).where(:user_id => @user.id)

    if (@existing_vote.empty?)
      # Update the question table votecount value
      @question.decrement(:votecount)
      @question.save!

      # Update the Votes table with the new vote
      Vote.create(
        :user_id => @user.id,
        :question_id => params[:id],
        :vote_type => "downvote")
    elsif (@existing_vote.pluck(:vote_type)[0] == "upvote")
      # Change the question from downvote to upvote
      @existing_vote.first.update_attributes(vote_type: "downvote")

      # Increment counter by 2 to counter the downvote
      @question.decrement(:votecount, 2)
      @question.save!
    end

    respond_to do |format|
      format.js
    end
  end

  # Method that is called when a question is created
  def create
    if(@user == nil)
      check_guest()
    end

    # For Multiple Choice Questions, concatenate the answer boxes into
    # one string, checking for empty boxes and removing them
    13.times do |count|
      counter = "answer_box_#{count}".to_sym
      unless (params[counter].to_s.empty?)
        @answerboxes = @answerboxes.to_s + params[counter].to_s << '|'
      end
    end

    # Strip the last comma from multiple choice questions
    if @answerboxes
      @answerboxes = @answerboxes[0...-1]
    end

    @subquestion = Question.create(
      :label => params[:submit_question_name],
      :group_id => params[:group_id],
      :user_id => @user.id,
      :value_type => params[:value_type],
      :options_for_collection => @answerboxes)

    GroupsQuestion.create(group_id: params[:group_id], question_id: @subquestion.id)

    if @subquestion.valid?
      redirect_to question_path(@subquestion), flash: { share_modal: true }
    else
      redirect_to categories_path
      flash[:notice] = "This Question has already been asked"
    end
  end

end
