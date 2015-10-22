class FeedController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"
  respond_to :html, :json

  def index
    cookies[:signup] = nil
    cookies[:answer] = nil
    cookies[:q] = nil

    check_guest()
    if(cookies[:guest] == nil)
      check_guest()
    end

    cookies[:group_id] = nil
    @all = Question.where.not(id: @question, shared_image: false).all.order(created_at: :desc).page(params[:page])
  end

  def category_non_feed
    cookies[:group_id] = params[:group_id]
    @all = Question.where(group_id: params[:group_id]).page(params[:page])
    #@all = Question.all.order(created_at: :desc).page(params[:page]).per(15)
    respond_to do |format|
      format.html { render :template => "feed/index" }
    end
  end

  def category
    cookies[:group_id] = params[:group_id]
    @all = Question.where(group_id: params[:group_id]).page(params[:page])
    respond_to do |format|
      format.js
    end
  end
end
