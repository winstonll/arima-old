class QuestionsController < ApplicationController
  include DetermineUserAndUnits

  require 'open-uri'
  layout "application_fluid"

  skip_before_filter :verify_authenticity_token, :only => :create

  # Show method - called when question page is rendered
  def show
    @question = Question.where(slug: params[:id])[0]

    if @question.nil?
      redirect_to feed_path
      return
    end

    cookies[:group_id] = @question.group_id
    #@answers = Answer.where(question: @question).count

    @counter = User.joins(:opinions).where("opinions.question_id = #{@question.id}").distinct.count

    @tags_array = Tag.where(question_id: @question.id).where("counter > ?", -2).order(created_at: :asc)
    @tagrave = Tag.where(:question_id => @question).where("counter < ?", -1)

    #Tag.where(question_id: @question.id).each do |tag|
    #  if tag.reply_id == 0
    #    @tags_array.push(tag)
    #  else
    #    @tags_array.insert(@tags_array.index(Tag.where(id: tag.reply_id).first) + 1, tag)
    #  end
    #end

    #extracting all of the users that answered this question
    #@users_list = Array.new
    #Answer.where(question: @question).find_each do |answer|
    #  @users_list << answer.user_id
    #end

    #extracting all of the countries that answered the question
    #@countries_array = Array.new
    #@users_list.each do |user|
    #  @countries_array << Location.where(user_id: user).pluck(:country)
    #end

    #@countries_array is a two dimensional array, so this extracts the first element of each inner array.
    #@countries_answered = @countries_array.collect(&:first).uniq

    #create_dummy_users()
    check_guest()

    #if cookies[:guest] != nil
    #  @user_country = Location.where(user_id: cookies[:guest]).first
    #  @dropdown_array = [@user_country.country]

    #  check_guest()

    #  @answer = user_signed_in? ? @question.answers.where(user_id: current_user.id).first : @question.answers.where(user_id: cookies[:guest]).first

    #  if @answer.nil?
    #    @user_submitted_answer = false
    #    @answer = user_signed_in? ? @question.answers.build(user_id: current_user.id) : @question.answers.build(user_id: cookies[:guest])
    #  else
    #    @user_submitted_answer = true
    #  end
    #end
  end

  def user_list_display
    @question = Question.where(slug: params[:question]).first
    @users_list = User.joins(:opinions).where("opinions.question_id = #{@question.id}").distinct

    respond_to do |format|
      format.js
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

  def new_modal

    @category_options = [['Select Category', 0], ["Funny", 5], ["Sports", 6], ["Entertainment", 7],
      ["Travel & Lifestyle", 8], ["Food & Health", 9], ["Current Events", 10], ["Interesting", 12], ["Gaming", 14]]

    respond_to do |format|
      format.js
    end
  end

  # Method that is called when a question is created
  def create

    if !verify_recaptcha
      redirect_to :back
      flash[:notice] = "Please verify that you are not a bot"
      return
    end

    if params[:submit_question_name].empty?
      redirect_to :back
      flash[:notice] = "Please enter a question Title/Description"
      return
    end

    # For Multiple Choice Questions, concatenate the answer boxes into
    # one string, checking for empty boxes and removing them
    #13.times do |count|
    #  counter = "answer_box_#{count}".to_sym
    #  unless (params[counter].to_s.empty?)
    #    @answerboxes = @answerboxes.to_s + params[counter].to_s << '|'
    #  end
    #end

    if !params[:question].nil?
      @question_image = true
      @uploaded_image = true
      @tag_number = 0
      uploaded_io = params[:question][:image_link]
      @file_name = "#{SecureRandom.hex[0,5]}.png"
      File.open(Rails.root.join('public', 'system', 'uploads', @file_name), 'wb') do |file|
        file.write(uploaded_io.read)
      end
    elsif !params[:submit_question_image].empty?
      @file_name = "#{SecureRandom.hex[0,5]}.png"
      download = open(params[:submit_question_image])
      IO.copy_stream(download, Rails.root.join('public', 'system', 'uploads', @file_name))
    end

    @user_created = user_signed_in? ? current_user.id : cookies[:guest]

    if (params[:submit_question_name].length < 256)

      @subquestion = Question.create(
        :label => params[:submit_question_name].slice(0,1).capitalize + params[:submit_question_name].slice(1..-1),
        :group_id => params[:question][:group_id],
        :user_id => @user_created,
        :value_type => "tag", #params[:numeric_value] == "false" ? "collection" : "quantity"
        :options_for_collection => "",
        :tag_count => @tag_number,
        :image_link => @file_name,
        :shared_image => true)

      GroupsQuestion.create(group_id: 7, question_id: @subquestion.id)
    else
      redirect_to categories_path
      flash[:notice] = "The length of the question was too long. Please try again."
      return
    end

    if @subquestion.valid?

      @user = User.where(id: @user_created).first

      @user.points = @user.points + 10
      @user.save

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
