class CountryController < ApplicationController
  @@data = File.read(Rails.root.join('app/assets/data/country.json'))
  def index
    render :json => @@data
  end
end
