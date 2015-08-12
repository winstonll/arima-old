class Opinion < ActiveRecord::Base
  belongs_to :tags

  def user_lat_long_all(q_id)
    loc_arr = Array.new

    answer_arr = Opinion.where(question_id: q_id).pluck('DISTINCT user_id')

    answer_arr.each do |a|
      current = Location.where(user_id: a)[0]

      if((current.country != nil || current.province != nil || current.city != nil) && (decimals(current.latitude) > 1 || decimals(current.longitude) > 1))
        value = [current.latitude, current.longitude]
        loc_arr.push(value)
      end
    end

    return loc_arr
  end

  def decimals(a)
    num = 0
    if (a != nil)
      while(a != a.to_i)
          num += 1
          a *= 10
      end
    end
    num
  end
end
