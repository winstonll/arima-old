class FeedController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"
  respond_to :html, :json

  def index
    check_guest()
    if(cookies[:guest] == nil)
      check_guest()
    end

    cookies[:group_id] = nil
    @all = Question.all.order(created_at: :desc).page(params[:page]).per(15)
  end

  def category_non_feed
    cookies[:group_id] = params[:group_id]
    @all = Question.where(group_id: params[:group_id]).page(params[:page]).per(15)
    #@all = Question.all.order(created_at: :desc).page(params[:page]).per(15)
    respond_to do |format|
      format.html { render :template => "feed/index" }
    end
  end

  def category
    cookies[:group_id] = params[:group_id]
    @all = Question.where(group_id: params[:group_id]).page(params[:page]).per(15)
    respond_to do |format|
      format.js
    end
  end
end
