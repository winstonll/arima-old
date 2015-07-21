class QuestionsController < ApplicationController
  include DetermineUserAndUnits
  layout "application_fluid"

  skip_before_filter :verify_authenticity_token, :only => :create

  # Show method - called when question page is rendered
  def show
    @question = Question.where(slug: params[:id])[0]
    cookies[:group_id] = @question.group_id
    @answers = Answer.where(question: @question).count

    #extracting all of the users that answered this question
    @users_list = Array.new
    Answer.where(question: @question).find_each do |answer|
      @users_list << answer.user_id
    end
    #extracting all of the countries that answered the question
    @countries_array = Array.new
    @users_list.each do |user|
      @countries_array << Location.where(user_id: user).pluck(:country)
    end

    #@countries_array is a two dimensional array, so this extracts the first element of each inner array.
    @countries_answered = @countries_array.collect(&:first).uniq

    #create_dummy_users()
    check_guest()

    if cookies[:guest] != nil
      @user_country = Location.where(user_id: cookies[:guest]).first
      @dropdown_array = [@user_country.country]

      check_guest()

      @answer = user_signed_in? ? @question.answers.where(user_id: current_user.id).first : @question.answers.where(user_id: cookies[:guest]).first

      if @answer.nil?
        @user_submitted_answer = false
        @answer = user_signed_in? ? @question.answers.build(user_id: current_user.id) : @question.answers.build(user_id: cookies[:guest])
      else
        @user_submitted_answer = true
      end
    end
  end

  def report
    @question = Question.where(slug: params[:id])[0]
    @users_list = Array.new
    Answer.where(question: @question).find_each do |answer|
      @users_list << answer.user_id
    end
    #extracting all of the countries that answered the question
    @countries_array = Array.new
    @users_list.each do |user|
      @countries_array << Location.where(user_id: user).pluck(:country)
    end

    #@countries_array is a two dimensional array, so this extracts the first element of each inner array.
    @countries_answered = @countries_array.collect(&:first).uniq

    respond_to do |format|
      format.html
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

    check_guest()

    # Check to see if the question has already been voted on
    @existing_vote = Vote.where(:question_id => params[:id]).where(:user_id => user_signed_in? ? current_user.id : cookies[:guest])

    if (@existing_vote.empty?)
      # Update the question table votecount value
      @question.increment(:votecount)
      @question.save!

      if(!@question.user_id.nil?)
        # Give 1 point to the user who created the question
        q_owner = User.where(id: @question.user_id)[0]
        q_owner.points = q_owner.points + 1
        q_owner.save!
      end

      # Update the Votes table with the new vote
      Vote.create(
        :user_id => cookies[:guest],
        :question_id => params[:id],
        :vote_type => "upvote")
    elsif (@existing_vote.pluck(:vote_type)[0] == "downvote")
      # Change the question from downvote to upvote
      @existing_vote.first.update_attributes(vote_type: "upvote")

      if(!@question.user_id.nil?)
        # Give 2 point to the user who created the question
        q_owner = User.where(id: @question.user_id)[0]
        q_owner.points = q_owner.points + 2
        q_owner.save!
      end

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

    check_guest()

    # Check to see if the question has already been voted on
    @existing_vote = Vote.where(:question_id => params[:id]).where(:user_id => user_signed_in? ? current_user.id : cookies[:guest])

    if (@existing_vote.empty?)
      # Update the question table votecount value
      @question.decrement(:votecount)
      @question.save!

      if(!@question.user_id.nil?)
        # Subtract 1 point to the user who created the question
        q_owner = User.where(id: @question.user_id)[0]
        q_owner.points = q_owner.points - 1
        q_owner.save!
      end

      # Update the Votes table with the new vote
      Vote.create(
        :user_id => cookies[:guest],
        :question_id => params[:id],
        :vote_type => "downvote")
    elsif (@existing_vote.pluck(:vote_type)[0] == "upvote")
      # Change the question from downvote to upvote
      @existing_vote.first.update_attributes(vote_type: "downvote")

      # Increment counter by 2 to counter the downvote
      @question.decrement(:votecount, 2)
      @question.save!

      if(!@question.user_id.nil?)
        # subtract 2 point to the user who created the question
        q_owner = User.where(id: @question.user_id)[0]
        q_owner.points = q_owner.points - 2
        q_owner.save!
      end

    end

    respond_to do |format|
      format.js
    end
  end

  # Method that is called when a question is created
  def create
    if(!user_signed_in?)
      redirect_to "/users/sign_up"
      return
    end

    if params[:submit_question_name].empty?
      redirect_to :back
      flash[:notice] = "Please enter a question Title/Description"
      return
    end

    if params[:group_id].blank?
      redirect_to :back
      flash[:notice] = "Please select a Category"
      return
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

    if @answerboxes.nil? || @answerboxes.empty? || @answerboxes.size < 2
      redirect_to :back
      flash[:notice] = "Please fill in at least two answer choices"
      return
    end


    @question_image = !params[:image_link].empty?

    if(@question_image)
      image_array = params[:image_link].split("/")
      if ((params[:image_link].include? "imgur.com") && image_array.size >= 4)
        if (!(image_array.include? "i.imgur.com"))
          image_array[2] = "i.imgur.com"
          image_array[-1] = image_array.last + ".gif"
        end
        if image_array.include? "gallery"
          image_array.delete("gallery")
          params[:image_link] = image_array.join("/")
        else
          params[:image_link] = image_array.join("/")
        end
        @question_image = true
      else
        @question_image = false
      end
    end

    if params["checked"] != nil && (params[:submit_question_name].length < 256)
      @subquestion = Question.create(
        :label => params[:submit_question_name].slice(0,1).capitalize + params[:submit_question_name].slice(1..-1),
        :group_id => params[:group_id],
        :user_id => current_user.id,
        :value_type => "collection",
        :options_for_collection => @answerboxes,
        :answer_plus => true,
        :image_link => @question_image ? params[:image_link] : nil)

      GroupsQuestion.create(group_id: params[:group_id], question_id: @subquestion.id)

    elsif(params[:submit_question_name].length < 256)
      @subquestion = Question.create(
        :label => params[:submit_question_name].capitalize,
        :group_id => params[:group_id],
        :user_id => current_user.id,
        :value_type => "collection",
        :options_for_collection => @answerboxes,
        :answer_plus => false,
        :image_link => @question_image ? params[:image_link] : nil)

      GroupsQuestion.create(group_id: params[:group_id], question_id: @subquestion.id)
    else
      redirect_to categories_path
      flash[:notice] = "The length of the question was too long. Please try again."
      return
    end

    if @subquestion.valid?
      current_user.points = current_user.points + 10
      current_user.save
      if(user_signed_in?)
        check_points_badge
        check_question_badge
      end

      redirect_to question_path(@subquestion), flash: { share_modal: true }
    else
      redirect_to categories_path
      flash[:notice] = "This Question has already been asked"
    end
  end

  def edit
     @question = Question.friendly.find(params[:id])
  end

  def hide_share_modal
    if (!cookies[:guest].nil?)
      @guest = User.where(id: cookies[:guest]).first
      @guest.update_attributes(share_modal_state: "hide")
    end

    render :nothing => true
  end

  def show_share_modal
    if (!cookies[:guest].nil?)
      @guest = User.where(id: cookies[:guest]).first
      @guest.update_attributes(share_modal_state: "show_20")
    end

    render :nothing => true
  end
end
