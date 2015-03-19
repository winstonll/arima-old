module ProfileHelper
  def full_location(user)
    user.location.city && !user.location.city.empty? ? "#{user.location.city}, #{user.location.country}" : "#{user.location.country}"
  end

  def category_icon(id)
    case id
      when 1
        return "category-icons/Money Matters.png"
      when 2
        return "category-icons/Health & Fitness.png"
      when 3
        return "category-icons/Education & Knowledge.png"
      when 4
        return "category-icons/Electronics & Gadgets.png"
      when 5
        return "category-icons/Business & Career.png"
      when 6
        return "category-icons/Sports.png"
      when 7
        return "category-icons/Entertainment.png"
      when 8
        return "category-icons/Travel & Lifestyle.png"
      when 9
        return "category-icons/Food.png"
      when 10
        return "category-icons/Current Events.png"
    end
  end
end
