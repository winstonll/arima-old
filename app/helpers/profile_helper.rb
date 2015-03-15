module ProfileHelper
  def full_location(user)
    user.location.city && !user.location.city.empty? ? "#{user.location.city}, #{user.location.country}" : "#{user.location.country}"
  end
end
