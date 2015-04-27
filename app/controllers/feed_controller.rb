class FeedController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"
  respond_to :html, :json

  def index
    @all = Question.all.order(created_at: :desc)
  end
end
