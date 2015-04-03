class Location < ActiveRecord::Base
  belongs_to :user

  #validates :user_id, presence: true
  validates :country_code, presence: true

  geocoded_by :ip_address
  before_validation :geocode

  reverse_geocoded_by :latitude, :longitude
  before_validation :reverse_geocode


  def country_obj
    # return the object!

    ISO3166::Country[country_code]
  end

  def country
    country_name
  end

  def continent
    country_obj.continent
  end

  def country_name
    return unless country_code
    iso_country = ISO3166::Country[country_code]
    iso_country.translations[I18n.locale.to_s] || iso_country.name
  end

  def country_city
    cc = [country_name, self.city].compact.reject(&:empty?)
    cc.join(", ")
  end
end
