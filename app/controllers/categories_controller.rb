class CategoriesController < ApplicationController
  include DetermineUserAndUnits

  #skip_before_filter :verify_authenticity_token, :only => :create
  layout "application_fluid"
  respond_to :html, :json

  def index
    redirect_to feed_path
  end

  def show
    @question = Group.friendly.find(params[:id])

    # Show recent questions by default
    @all = @question.questions.order(created_at: :desc)

    # all questions answered by the user
    if session[:guest]
      user_questions = session[:guest].questions
      @answered         = @all & user_questions
      @unanswered       = @all - @answered
    end
  end

  def show_popular
    @question = Group.friendly.find(params[:id])
    @all = @question.questions.page(params[:page]).per(7)

    # displaying the questions by total user count
    @questions_hash = Hash.new
    @all.each do |question|
      @questions_hash[question] = question.users.count
    end
    @questions_hash = @questions_hash.sort_by { |question, count| count }.reverse

    @all_popular_questions = Hash[@questions_hash.map {|question, count| [question, count]}]
    @all = @all_popular_questions.keys
    # @all = Kaminari.paginate_array(@all_popular_questions.keys).page(params[:page]).per(7)

    # all questions answered by the user
    if session[:guest]
      user_questions = session[:guest].questions
      @answered         = @all_popular_questions.keys & user_questions
      @unanswered       = @all_popular_questions.keys - @answered
    end

    respond_to do |format|
      format.js
    end
  end

  def show_recent
    @question = Group.friendly.find(params[:id])

    @all = @question.questions.order(created_at: :desc)

    # all questions answered by the user
    if session[:guest]
      user_questions = @session[:guest].questions
      @answered         = @all & user_questions
      @unanswered       = @all - @answered
    end

    respond_to do |format|
      format.js
    end
  end

  private
end
