class FeedController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"
  respond_to :html, :json

  def index
    if(cookies[:guest] == nil)
      check_guest()
    end
    @all = Question.all.order(created_at: :desc).page(params[:page]).per(15)
  end

  def category
    @all = Question.all.where(group_id: params[:group_id]).page(params[:page]).per(15)
    respond_to do |format|
      format.html { render :template => "feed/index" }
    end
  end
end
