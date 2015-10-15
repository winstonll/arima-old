class TagsController < ApplicationController

  protect_from_forgery with: :exception

  #skip_before_filter :verify_authenticity_token, :only => :create
  #before_filter :authenticate_user!, except: [:intro_question, :show, :create, :show_image]
  include DetermineUserAndUnits

  layout "application_fluid"

  respond_to :json, :html, :js
  skip_before_filter :verify_authenticity_token, :only => :create


  def add_tag

    # cookies[:signup] = nil
    # cookies[:answer] = nil
    # cookies[:q] = nil

    @question = Question.where(id: params[:question_id]).first
    @label = params[:tag][:label].empty? ? params[:value] : params[:tag][:label]

    answer_user_id = user_signed_in? ? current_user.id : cookies[:guest]

    @x = params[:x_axis].to_f / params[:x_axis_max].to_f
    @y = params[:y_axis].to_f/params[:y_axis_max].to_f
    @tag = Tag.new(label: @label, question_id: @question.id,
    counter: 1, x_ratio: @x, y_ratio: @y)
    @tag.save

    @opinion = Opinion.new(question_id: @question.id, tag_id: @tag.id, user_id: answer_user_id)
    @opinion.save

    respond_to do |format|
      format.js
    end

  end

end
