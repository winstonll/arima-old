class FindPlaceholder
  attr_accessor :input_type, :user

  def initialize(input_type, user)
    @input_type = input_type
    @user = user
  end

  def placeholder
    {
      currency: user.currency_unit,
      quantity: "",
      length: user.measurement_unit,
      weight: user.weight_unit,
      text: nil,
      hours: "Hours",
      years: "Years",
      minutes: "Minutes"
    }[@input_type.to_sym] if @input_type
  end
end