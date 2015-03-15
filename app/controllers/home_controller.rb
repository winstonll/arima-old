class HomeController < ApplicationController
  def index
    if current_user && current_user.present?
        redirect_to categories_path
    end
  end
end
