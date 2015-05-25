class Question < ActiveRecord::Base
  extend FriendlyId
  friendly_id :label, use: :slugged, sequence_separator: '_'

  has_many :groups_questions
  has_many :groups, through: :groups_questions

  has_many :answers, :dependent => :destroy
  has_many :users, through: :answers

  # serialize :options_for_collection, Array


  ALLOWED_TYPES = [
    "currency", "quantity", "length",
    "weight", "text", "hours", "years",
    "minutes", "collection", "measurement"
  ]

  validates :label, presence: true
  validates :label, uniqueness: true
  validates :value_type, inclusion: { in: ALLOWED_TYPES }


  def country_name
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def percent_gender
    genders = self.users.pluck(:gender).compact
    males = genders.select{|p| p == "M"}.count
    females = genders.select{|p| p == "F"}.count
    total = genders.count.nonzero? || 1
    males_percent = (males.to_f / total * 100).round(0)
    females_percent = (females.to_f / total * 100).round(0)

    { males: males_percent, females: females_percent }
  end

  def average_age
    self.users.average('AGE(dob)').to_i
  end

  def user_country
    return users.joins(:location).pluck(:country).first.to_s
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

  def percent_world
    total_count = value_count_world.values.sum
    result = value_count_world.map{|k,v| {k => ((v.to_f / total_count.to_f) * 100).round(0)}}
    result.reduce({}, :update) # get rid of enclosing array, make it a hash instead
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
  end

  def value_count_world
    a = self.by_world.pluck(:value).compact

    ag = a.group_by{|value| value }
    ag.map{|k,v| {k => v.size} }.reduce({}, :update)
  end

  def by_country
    country_answer = self.answers.reduce({}) do |res, answ|
      key = answ.user.location.country
      res[key] ||= []
      res[key] << answ
      res
    end

    country_answer
  end

  def by_world
    Answer.where(question_id: self.id)
  end

  # displays input type in more user-friendly terms
  def input_type_user_view
    type_displayed = "Text input"       # default
    type_displayed = "Text input"       if ["text"].include? self.value_type
    type_displayed = "Numerical input"  if ["quantity"].include? self.value_type
    type_displayed = "Numerical input"  if ["currency", "length", "weight", "hours", "years", "minutes"].include? self.value_type
    type_displayed = "Single choice"    if ["collection"].include? self.value_type
    type_displayed = "Measurement"      if ["measurement"].include? self.value_type
    type_displayed
  end

  # This is needed to interact directly with the model
  # Do not modify it unless it's necessary.
  def input_type
    return nil unless value_type.present?
    response = "text"         # default
    response = "text"         if ["text"].include? self.value_type
    response = "integer"      if ["quantity"].include? self.value_type
    response = "float"        if ["currency", "length", "weight", "hours", "years", "minutes"].include? self.value_type
    response = "collection"   if ["collection"].include? self.value_type
    response = "measurement"  if ["measurement"].include? self.value_type
    response
  end

  def user_lat_long
    arr = Hash.new
    loc_arr = Array.new

    answer_arr = Answer.where(question_id: self)
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
    if self.value_type == "collection"
      case value
        when "city" then collection_data percent_city
        when "country" then collection_data percent_country
        when "world" then collection_data percent_world
      end
    else
      case value
        when "city" then numeric_data by_city.pluck(:value).compact
        when "country" then numeric_data by_country.pluck(:value).compact
        when "world" then numeric_data by_world.pluck(:value).compact
      end
    end
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
  
  def collection_data(value)
    arr = Array.new
    value.map do |key, val|
      arr.push [key, val]
    end
    arr.to_s
  end

  def numeric_aggregation(list)
    #raw_value = value
    if self.input_type == 'integer' then
      list = list.map(&:to_i)
      #raw_value = value.to_i
    elsif self.input_type == 'float' then
      list = list.map(&:to_f)
      #raw_value = value.to_f
    end
    list.sort!
    aggregated_list = list.each_with_object(Hash.new(0)) { |i,h| h[i] += 1; h }
    #index = list.index(raw_value)
    return aggregated_list
  end

  def numeric_data(list)
    data, = numeric_aggregation list
    return data.to_a.to_s
  end

  def average_world
    a = self.by_world.pluck(:value).compact

    return 0 unless a.any?
    average = a.map(&:to_f).reduce(:+).to_f / a.size.to_f
    average.round(2)
  end

  def options_array
    options = self.options_for_collection
    unless options.nil?
      options = options.squish!.split("|")
      options.map{ |v| v.strip }
    end
  end

  def placeholder(user)
    FindPlaceholder.new(self.value_type, user).placeholder
  end

  def value_symbol
    return nil unless value_type.present?
    {
      currency: "$",
    }[value_type.to_sym]
  end

  def self.suggested_for_user(user)
    answered_questions_ids = user.answered_questions_ids
    group_ids_with_count = Group.groups_usage_for_user(user).first(3)
    group_ids = group_ids_with_count.map{|gc| gc[0] }

    excluded_ids = []
    questions = Group.find(group_ids)
                     .map{|g|
                       question = g.questions
                                   .order("questions.created_at DESC")
                                   .where("questions.id NOT IN (?)", answered_questions_ids + excluded_ids)
                                   .first

                       excluded_ids << question.id if question
                       question
                     }
    questions.compact
  end

  def self.random_for_user(user, n=3)
    answered_questions_ids = user.answered_questions_ids
    self.where("questions.id NOT IN (?)", answered_questions_ids).sample(n)
  end

  def self.trending(exclude=[], n=3)
    connection = ActiveRecord::Base.connection
    if exclude.any?
      result = connection.execute("SELECT question_id, COUNT(answers.question_id) AS repeats FROM answers WHERE answers.question_id NOT IN(#{exclude.join(',')}) GROUP BY question_id ORDER BY repeats DESC, question_id DESC LIMIT #{n}")
    else
      result = connection.execute("SELECT question_id, COUNT(answers.question_id) AS repeats FROM answers GROUP BY question_id ORDER BY repeats DESC, question_id DESC LIMIT #{n}")
    end
    result
  end

  def self.trending_for_user(user, n=3)
    exclude_ids = user.answered_questions_ids
    trending_question_ids = self.trending(exclude_ids).to_a.map{|res| res.values.first}
    self.where(id: trending_question_ids)
  end

  def validates_numericality?
    (self.value_type == "collection" || self.value_type == "text") ? false : true
  end

  # FRONT END VALIDATION
  def validation_message
    if validates_numericality?
      "Please ensure your answer is no less than 0"
    end
  end

  def min_value
    # make sure the Answer numericality validator matches
    if self.validates_numericality?
      0
    end
  end
end
