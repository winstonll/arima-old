class HomeController < ApplicationController
  def index
    if current_user && current_user.present?
        redirect_to feed_path
    end
  end
end
