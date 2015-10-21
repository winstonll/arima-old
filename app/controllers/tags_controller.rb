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

  def vote_tag
    check_guest()

    @question = Question.where(id: params[:question]).first
    @tags_array = Tag.where(question_id: params[:question])
    @tag_clicked = params[:tag_clicked]
    @tag = Tag.where(id: params[:tag_clicked]).first

    @user_id = user_signed_in? ? current_user.id : cookies[:guest]

    if Opinion.where(tag_id: @tag.id, user_id: @user_id).first.nil?
      @tag.counter = @tag.counter + 1
      @tag.save

      @opinion = Opinion.new(tag_id: @tag.id, user_id: @user_id, question_id: params[:question])
      @opinion.save
    else
      @opinion = Opinion.where(tag_id: @tag.id, user_id: @user_id).first

      if @opinion.vote_type == 'downvote'
        @tag.counter = @tag.counter + 2
        @tag.save
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def downvote_tag
    check_guest()

    @question = Question.where(id: params[:question]).first
    @tags_array = Tag.where(question_id: params[:question])
    @tag_clicked = params[:tag_clicked]
    @tag = Tag.where(id: params[:tag_clicked]).first

    @user_id = user_signed_in? ? current_user.id : cookies[:guest]

    if Opinion.where(tag_id: @tag.id, user_id: @user_id).first.nil?
      @tag.counter = @tag.counter + 1
      @tag.save

      @opinion = Opinion.new(tag_id: @tag.id, user_id: @user_id, question_id: params[:question])
      @opinion.save
    else
      @opinion = Opinion.where(tag_id: @tag.id, user_id: @user_id).first

      if @opinion.vote_type == 'upvote'
        @tag.counter = @tag.counter - 2
        @tag.save
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def graveyard_list
    @question = Question.where(slug: params[:question]).first
    @opinion = Opinion.where(tag_id: @tag, user_id: @user_id).first

    respond_to do |format|
      format.js
    end
  end

end
