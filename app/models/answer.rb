class Answer < ActiveRecord::Base

  belongs_to :user
  belongs_to :question

  validates :user_id,     presence: true
  validates :question_id, presence: true,
                           uniqueness: {
                            scope: :user_id,
                            message: "Cannot submit duplicate answers"
                           }
  validates :value,       presence: true

  # make sure the Question min_value matches
  validates :numerical_value, numericality: { greater_than_or_equal_to: 0 }, if: :validates_numericality?

  before_save :clean_value
  # after_create :point_for_user

  # virtual attribute for numericality validator
  def numerical_value
    self.value.to_f
  end

  # get user prefered values for placeholder
  def placeholder
    self.question.placeholder(self.user)
  end

  def value_symbol
    self.question.value_symbol
  end

  # DECORATORS / VIEW HELPERS

  def color_generator
    @generator ||= ColorGenerator.new saturation: 0.8, value: 0.8, seed: 123456789
  end

  # this is only used for description that is generated for shares.
  def value_format
    if self.question.value_type == "collection"
      self.value
    else
      "#{self.value_symbol}#{self.value} #{self.placeholder}"
    end
  end

  # the comparison text under each location category
  def formatted_diff_average(location)
    if self.question.value_type == "collection"
      case location
        when 'city'
          collection = percent_city
          location = user.location.city
        when 'country'
          collection = percent_country
          location = user.location.country
        when 'world'
          collection = percent_world
          location = 'the whole world'
      end
      "In #{location}, #{collection[value]}% of people selected #{value}".html_safe
    else
      case location
        when 'city'
          average = average_city
          location = user.location.city
          loc_addr = 'city'
        when 'country'
          average = average_country
          location = user.location.country
          loc_addr = 'national'
        when 'world'
          average = average_world
          location = 'all over the world'
          loc_addr = 'global'
      end
      diff = percent_diff value, average
      response = "Compared to people from #{location}, #{value_symbol}#{value} #{placeholder} is"
      response += " #{diff == 0 ? '' : diff.abs.to_s + '%'} #{less_more diff} the"
      response += " #{loc_addr} average (#{value_symbol}#{average} #{placeholder})"
      response.html_safe
    end
  end

  def formatted_diff_rank(val)
    return nil if self.question.value_type == "collection"

    "<h1 style='color:##{color_generator.create_hex}'>#{val}% Rank</h1>".html_safe
  end

  # def country_answer
  #   self.formatted_diff_average 'country'
  # end

  def city_answer
    self.formatted_diff_average 'city'
  end

  def description
    ActionController::Base.helpers.strip_tags("#{self.question.label}")
  end

  # def chart(value)
  #   if self.question.value_type == "collection"
  #     case value
  #       when "city" then collection_chart percent_city
  #       when "country" then collection_chart percent_country
  #       when "world" then collection_chart percent_world
  #     end
  #   else
  #     case value
  #       when "city" then numeric_chart by_city.pluck(:value).compact
  #       when "country" then numeric_chart by_country.pluck(:value).compact
  #       when "world" then numeric_chart by_world.pluck(:value).compact
  #     end
  #   end
  # end

  def user_country
    return user.location.country.to_s
  end

  def center_lat_long
    loc = Location.where(user_id: self.user_id)[0]
    arr = [loc.latitude.to_s, loc.longitude.to_s]
    return arr
  end

  def user_answer
    return self.value.to_s
  end

  def user_age
    return user.age
  end

  def user_gender
    return user.gender.to_s
  end

  def user_lat_long
    arr = Hash.new
    loc_arr = Array.new

    answer_arr = Answer.where(question_id: self.question_id)
    answer_arr.each do |a|
      if (arr[a.value])
        current = Location.where(user_id: a.user_id)[0]
        if((current.country != nil || current.province != nil || current.city != nil) && (decimals(current.latitude) > 1 || decimals(current.longitude) > 1))
          arr[a.value].push(current.latitude.to_s + ", " + current.longitude.to_s)
        end
      else
        current = Location.where(user_id: a.user_id)[0]
        if((current.country != nil || current.province != nil || current.city != nil) && (decimals(current.latitude) > 1 || decimals(current.longitude) > 1))
          arr[a.value] = Array.new().push(current.latitude.to_s + ", " + current.longitude.to_s)
        end
      end
    end
    return arr
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

  def data_array(value)
    if self.question.value_type == "collection"
      case value
        when "city" then collection_data percent_city
        when "country" then collection_data percent_country
        when "world" then collection_data percent_world
        #when "pstm" then collection_data percent_pstm
      end
    else
      case value
        when "city" then numeric_data by_city.pluck(:value).compact
        when "country" then numeric_data by_country.pluck(:value).compact
        when "world" then numeric_data by_world.pluck(:value).compact
        #when "pstm"
      end
    end
  end

  def collection_data(value)
    arr = Array.new
    value.map do |key, val|
      arr.push [key, val]
    end
    arr.to_s
  end

  def numeric_aggregation(list)
    raw_value = value
    if question.input_type == 'integer' then
      list = list.map(&:to_i)
      raw_value = value.to_i
    elsif question.input_type == 'float' then
      list = list.map(&:to_f)
      raw_value = value.to_f
    end
    list.sort!
    aggregated_list = list.each_with_object(Hash.new(0)) { |i,h| h[i] += 1; h }
    index = list.index(raw_value)
    return aggregated_list, index
  end

  def numeric_data(list)
    data, = numeric_aggregation list
    return data.to_a.to_s
  end

  def collection_chart(value)
    temp_distinct = Time.now.usec
    html = "
      <div style='height: 200px;'>
        <svg id='pie-chart-collection-#{ self.id }-#{ temp_distinct }'></svg>
      </div>
      <script>
        var data = ["
    value.map do |key, val|
      html += "{key: '#{key.gsub("'", "`")}', val: #{val}},"
    end
    # var location_charts_width is decleared in answer partial
    html += "
        ];
        visualization.drawPieChart(
          '#pie-chart-collection-#{ self.id }-#{ temp_distinct }',
          data,
          {
            labelType: 'percent',
            height: 200,
            width: location_charts_width,
            colors: #{Array.new(value.length).map { '#'+color_generator.create_hex }},
            tooltipFunc: function (key, y, e, graph) {
              return key + ': ' + y + '%';
            }
          }
        );
      </script>
    "
    html.html_safe
  end

  def numeric_chart(list)
    return
    temp_distinct = Time.now.usec
    aggregated_list, index = numeric_aggregation list

    html = "
      <div style='height: 200px;'>
        <svg id='numeric-bar-chart-#{ self.id }-#{ temp_distinct }'></svg>
      </div>
      <script>
        var data = [ { key: '#{ question.label }', values: [ "
    aggregated_list.map do |key, val|
      html += "{label: '#{key}', value: #{val}},"
    end
    # var location_charts_width is decleared in answer partial
    html += "
        ] } ];
        visualization.drawDiscreteBarChart(
          '#numeric-bar-chart-#{ self.id }-#{ temp_distinct }',
          data,
          {
            height: 200,
            width: location_charts_width,
            colors: #{Array.new(aggregated_list.length).map { '#'+color_generator.create_hex }},
            tooltipFunc: function (key, y, e, graph) {
              return e + ' ' + (e == 1 ? 'person' : 'people');
            },
            debugFunc: function (chart) {
              chart.margin({top: 30})
            }
          }
        );
      </script>
    "
    html.html_safe
  end

  # MODEL HELPERS

  # get id of users in the same city that answered the same question
  def user_ids_for_city
    self.question.users
      .joins(:location)
      .where("locations.city = ?", self.user.location.city)
      .pluck(:id).compact
  end

  def by_city
    Answer.where(question_id: self.question_id, user_id: user_ids_for_city)
  end

  # def user_ids_for_country
  #   self.question.users
  #     .joins(:location)
  #     .where("locations.country_code = ?", self.user.location.country_code)
  #     .pluck(:id).compact
  # end

  def by_country
    country_answer = question.answers.reduce({}) do |res, answ|
      unless user == nil
      key = answ.user.location.country
      res[key] ||= []
      res[key] << answ
      res
      end
    end

    country_answer
  end

  def by_world
    Answer.where(question_id: question_id)
  end

  # PERCENT DIFFERENCE FROM AVERAGE

  def percent_diff(val, average)
    ((val.to_f / average.to_f * 100) - 100).round(2)
  end

  # AVERAGES

  def average_city
    a = self.by_city.pluck(:value).compact

    return 0 unless a.any?
    average = a.map(&:to_f).reduce(:+).to_f / a.size.to_f
    average.round(2)
  end

  def average_country
    a = self.by_country.pluck(:value).compact

    return 0 unless a.any?
    average = a.map(&:to_f).reduce(:+).to_f / a.size.to_f
    average.round(2)
  end

  def average_world
    a = self.by_world.pluck(:value).compact

    return 0 unless a.any?
    average = a.map(&:to_f).reduce(:+).to_f / a.size.to_f
    average.round(2)
  end

  def average_age
    self.question.users.average('AGE(dob)').to_i
  end

  def percent_gender
    genders = self.question.users.pluck(:gender).compact
    males = genders.select{|p| p == "M"}.count
    females = genders.select{|p| p == "F"}.count
    total = genders.count.nonzero? || 1
    males_percent = (males.to_f / total * 100).round(0)
    females_percent = (females.to_f / total * 100).round(0)

    { males: males_percent, females: females_percent }
  end

  # multiple choice questions

  def percent_city
    total_count = value_count_city.values.sum
    result = value_count_city.map{|k,v| {k => ((v.to_f / total_count.to_f) * 100).round(0)}}
    result.reduce({}, :update) # get rid of enclosing array, make it a hash instead
  end

  def percent_country
    country_values = value_count_country
    total_count = country_values.delete('total_count')

    result = country_values.flat_map do |country,categories|
      # categories.map {|category,value| {category => ((value.to_f / total_count.to_f) * 100).round(0)}}
      categories.map {|category,value| {category => value.to_f}}
    end
    country_values['totals'] = result.reduce({}, :update) # get rid of enclosing array, make it a hash instead\
    country_values.reduce({}){|m, (k,v)| m[k] = v.to_a; m}
  end

  def numeric_country
    country_values = by_country.reduce({}) do |res, (country, answers)|
      country_values = answers.map(&:value).compact.group_by{|v| v}
      res[country] = Hash[country_values.map{|k,v| [k.to_f, v.size]}]
      res
    end
    result = country_values.flat_map do |country,categories|
      categories.map {|category,value| {category => value.to_f}}
    end
    country_values.reduce({}){|m, (k,v)| m[k] = v.to_a; m}
  end

  def percent_world
    total_count = value_count_world.values.sum
    result = value_count_world.map{|k,v| {k => ((v.to_f / total_count.to_f) * 100).round(0)}}
    result.reduce({}, :update) # get rid of enclosing array, make it a hash instead
  end

  def percent_pstm
    year = self.user.birthyear
    gender = self.user.gender
    arr = {}
    total = 0

    Answer.where(question_id: self.question_id).find_each do |answer|
      if(answer.user.birthyear != nil && answer.user.gender == gender && answer.user.birthyear <= year + 3 && answer.user.birthyear >= year - 3)
        total = total + 1
        if(arr[answer.value] == nil)
          arr[answer.value] = 1.0
        else
          arr[answer.value] = arr[answer.value] + 1.0
        end
      end
    end

    arr.each do |k , v|
      arr[k] = ((arr[k] /total) * 100).round(0)
    end

    return arr
  end

  def value_count_city
    a = self.by_city.pluck(:value).compact

    ag = a.group_by{|value| value }
    ag.map{|k,v| {k => v.size} }.reduce({}, :update)
  end

  def value_count_country
    answers_per_country = by_country
    values_per_country = by_country.reduce({}) do |res, (country, answers)|
      country_values = answers.map(&:value).compact.group_by{|v| v}
      res[country] = Hash[country_values.map{|k,v| [k, v.size]}]
      res
    end
    values_per_country['total_count'] = answers_per_country.values.map(&:count).sum
    values_per_country
    # a = self.by_country.pluck(:value).compact

    # ag = a.group_by{|value| value }
    # ag.map{|k,v| {k => v.size} }.reduce({}, :update)
  end

  def value_count_world
    a = self.by_world.pluck(:value).compact

    ag = a.group_by{|value| value }
    ag.map{|k,v| {k => v.size} }.reduce({}, :update)
  end

  # these used for output

  def less_more(value)
    return "less than" if value < 0
    return "more than" if value > 0
    return "equal to" if value == 0
  end

  # RANKS

  def my_percent_rank(user_ids=nil)
    # to guard against intro questions graph calculations where self does not usually have an id...
    return nil unless self.question.id.present? && self.id.present?

    if !user_ids.blank?
      sql = %Q{
        SELECT id,value,percent_rank FROM (
          SELECT id,value,percent_rank() OVER (PARTITION BY question_id ORDER BY (0 || value)::float ASC)
          FROM answers
          WHERE question_id = #{self.question.id} AND user_id IN (#{user_ids.join(',')})
        ) AS bar WHERE id = #{self.id}
      }
    else
      sql = %Q{
        SELECT id,value,percent_rank FROM (
          SELECT id,value,percent_rank() OVER (PARTITION BY question_id ORDER BY (0 || value)::float ASC)
          FROM answers
          WHERE question_id = #{self.question.id}
        ) AS bar WHERE id = #{self.id}
      }
    end

    Answer.find_by_sql(sql).first.percent_rank
  end

  def rank_percent_city
    return nil if self.question.value_type == "collection"

    user_ids = user_ids_for_city
    rank = my_percent_rank user_ids

    (rank * 100).round(1) if rank
  end

  def rank_percent_country
    return nil if self.question.value_type == "collection"

    user_ids = user_ids_for_country
    rank = my_percent_rank user_ids

    (rank * 100).round(1) if rank
  end

  def rank_percent_world
    return nil if self.question.value_type == "collection"

    rank = my_percent_rank

    (rank * 100).round(1) if rank
  end

  # POINTS

  def point_for_user
    User.increment_counter(:points, self.user_id)
    award_bonus_for_daily_max
  end

  def award_bonus_for_daily_max
    # do not award a bonus if one already awarded for today
    return if self.user.daily_score_award_date.present? &&
              self.user.daily_score_award_date >= Date.current

    # today's score must be higher than previous top daily score
    # previous top daily score must be above 0 (0 might indicate a newly created user)
    if self.user.todays_score.to_i > self.user.top_daily_score.to_i &&
       self.user.top_daily_score.to_i > 0

      self.user.points = self.user.points + 3
      self.user.daily_score_award_date = Date.current

      self.user.save!
    end
  end

  # generate thumbnail for shares
  def generate_image
    title = 'World answers to ' + question.label
    if self.question.value_type == "collection"
      # generate pie chart
      g = Gruff::Pie.new
      g.title = title
      g.title_font_size = 30
      g.legend_font_size = 15
      g.marker_font_size = 15
      # g.text_offset_percentage = 0.3
      collection = percent_world
      collection.each do |key, val|
        g.data(key, val)
      end
    else
      # generate bar chart
      list = by_world.pluck(:value).compact
      if question.input_type == 'integer' then
        list = list.map(&:to_i)
      elsif question.input_type == 'float' then
        list = list.map(&:to_f)
      end
      list.sort!
      aggregated_list = list.each_with_object(Hash.new(0)) { |i,h| h[i] += 1; h }
      g = Gruff::Bar.new
      g.title = title
      g.title_font_size = title.length > 50 ? 20 : 30
      g.title_margin = 50
      g.hide_legend = true
      labels = {}
      data = []
      aggregated_list.each_with_index do |(key, val), idx|
        labels.store(idx, key.to_s)
        data.append(val)
      end
      g.labels = labels
      g.data :data, data
      g.x_axis_label = "#{placeholder}#{ value_symbol ? " (#{value_symbol})" : nil}"
      g.y_axis_label = "population"
      g.y_axis_increment = 1
      g.minimum_value = 0
    end

    return g
  end

  # SANITIZE/CLEAN

  def clean_value
    self.value = self.value.to_s.strip
  end

  def validates_numericality?
    self.question.validates_numericality?
  rescue NoMethodError
    # fallback to stricter check
    true
  end

end
