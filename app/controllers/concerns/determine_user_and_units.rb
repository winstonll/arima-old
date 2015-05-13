module DetermineUserAndUnits
  extend ActiveSupport::Concern

  included do
    before_filter :set_user
    before_filter :determine_units
  end

  private

  def set_user
    @user = session[:guest]
  end

  def determine_units
    if @user
      measure_type = @user.measurement_unit.downcase
    else
      measure_type = "metric"
    end
    user_unit_terms = Hash.new
    user_unit_terms["large_unit"] = (measure_type == "metric") ? "meters" : "feet"
    user_unit_terms["small_unit"] = (measure_type == "metric") ? "centimeters" : "inches"
    @user_units = user_unit_terms
  end
end

