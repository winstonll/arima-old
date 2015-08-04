class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  has_one :location, :dependent => :destroy
  has_many :answers, :dependent => :destroy
  has_many :badges, dependent: :destroy
  has_many :questions, through: :answers
  has_many :submit_questions

  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100#" },
    :default_url => ActionController::Base.helpers.asset_path("missing.png")

  accepts_nested_attributes_for :location,
    reject_if: proc { |bar| bar[:country_code].blank? }

  # GENDER_OPTIONS = ['M', 'F']
  # GENDER_ALIAS = { 'Male' => 'M', 'Female' => 'F' }

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  #comment out for now, bring it back when we bring back signup.

  validates :email, presence: true, uniqueness: true, unless: "username.nil?"
  validates :password, presence: true, :confirmation => true,
      length: { :in => 8..20 }, :on => :create, unless: "last_emailed_at.nil?"
  validates :username, presence: true, uniqueness: true, unless: "username.nil?"

  #validates :gender, presence: true
  #validates :birthyear, presence: true
  #validates :ip_address, presence: true
  # validates :gender, inclusion: { in: gender_options }, allow_nil: true

  before_validation do
    case gender
    when /^m/i
      self.gender = "M"
    when /^f/i
      self.gender = "F"
    else
      self.gender = nil
    end
  end

  def display_name
    if self.first_name.present?
      "#{first_name} #{self.last_name.present? ? self.last_name : '' }"
    else
      self.username
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def age
    now = Date.today

    # Fallback if user doesn't have birthyear for some reason
    if self.birthyear
      now.year - self.birthyear
    else
      now.year - 1965
    end
  end

  def is_set_up?
    if self.first_name.present? &&
       self.gender.present?     &&
       self.age.present?        &&
       self.location.present?
      true
    else
      false
    end
  end

  def self.is_ready_to_set_up?(session_params)
    return false unless session_params.present?

    if session_params["first_name"].present? 		     &&
       session_params["birthdate"].present? 		     &&
       session_params["gender"].present?    		     &&
       session_params["units"].present?
       true
    else
      false
    end
  end

  def self.gender_options
    { 'Male' => 'M', 'Female' => 'F' }
  end

  def set_username
    self.username = SecureRandom.uuid unless self.username.present?
  end

  def currency_unit
    self[:currency_unit].present? ? self.currency_unit : self.location.country_obj.currency.code
  rescue NoMethodError
    'USD'
  end

  def measurement_unit
    self[:measurement_unit] || "Metric"
  end

  def weight_unit
    {
      "Metric" => "Kilograms",
      "Imperial" => "Pounds"
    }[self.measurement_unit]
  end

  def length_unit
    {
      "Metric" => "Meters",
      "Imperial" => "Feet"
    }[self.measurement_unit]
  end

  def most_active_category
    Group.most_active_group_for_user self
  end

  def most_active_categories(n=3)
    Group.most_active_groups_for_user(self, n)
  end

  # Returns an array of questions answered.
  # Note: Rails treats an empty array as NIL, be sure to handle this
  def answered_questions_ids
    self.questions.pluck(:id)
  end

  # -1 day (do not count today's points)
  def top_daily_score
    result = Answer.find_by_sql(%Q{
      SELECT MAX(foobar.answer_count) AS score
        FROM (
          SELECT DATE(created_at) AS created_date, COUNT(DATE(created_at)) AS answer_count
          FROM answers
          WHERE user_id = #{self.id} AND DATE(created_at) != DATE('#{Date.current}')
          GROUP BY DATE(created_at)
          ORDER BY DATE(created_at) DESC
        ) AS foobar
    })

    (result.any? && result.first.score) ? result.first.score : 0
  end

  def todays_score
    Answer.where(user_id: self.id, created_at: Date.current.beginning_of_day..Date.current.end_of_day).count
  end

  def show_top_daily_score?
    return false if self.daily_score_award_date == Date.current
    return false if Answer.where(user_id: self.id).order("created_at ASC").first.created_at.end_of_day >= Date.current.end_of_day

    return true
  end

  def forgot_password_email
    generate_token(:password_reset_token)
    save!
    UserMailer.forgot_password_email(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  # Leaderboard functions
  def self.get_ranked_users
    all.joins(:location).order(points: :desc)
  end

  def get_user_rank
    User.get_ranked_users.index(self) + 1
  end

end
