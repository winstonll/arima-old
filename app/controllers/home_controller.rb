class HomeController < ApplicationController
  def index
    if current_user && current_user.present?
        redirect_to feed_path
    end
  end

  def signup_modal
    respond_to do |format|
      format.js
    end
  end
end
