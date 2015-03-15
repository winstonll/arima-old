class ReportsController < ApplicationController
  before_filter :setup

  layout "application_fluid"

  def index
    all_answers = @resource.answers
    @answers = params[:expand].present? ? all_answers : all_answers.sample(3)
  end

  def show
    @answers = Answer.where(id: params[:answer_id], user_id: @resource.id)
    answer = @answers.first # because we are still using the index view which expect this array

    @set_og = true # set open graph info for this resource

    render plain: 'not found' and return unless answer

    # check duplicates in the answers controller
    city = answer.user.location.city if answer.user.location.city.present?
    country = answer.user.location.country if answer.user.location.country.present?
    # for the view
    @image = "#{request.protocol}#{request.host_with_port}#{answer_thumb_path(params[:answer_id])}"
    @title = "Arima Report"
    @description = answer.description
    @url = answer_url(@answer.id)

    #This is to create custom views for a report
    if user_signed_in? 
      render template: "reports/index" and return
    else 
      render template: "reports/shared_report" and return
    end
  
  end

  private

  def setup
    @resource ||= User.where(username: params[:username]).first

    if user_signed_in?
      @points_count = @resource.points || 0
      @questions_count = @resource.questions.count
      @most_active_category = @resource.most_active_category.keys.first if @resource.most_active_category
      @trending_questions = Question.trending_for_user @resource
    end
  end
end
