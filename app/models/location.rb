class Location < ActiveRecord::Base
  belongs_to :user

  #validates :user_id, presence: true
  validates :country_code, presence: true

  geocoded_by :ip_address
  before_validation :geocode

=begin
  geocoded_by :latitude, :longitude
  before_validation :geocode
=end

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

=begin
  #http://larsgebhardt.de/advanced-geocoding-with-ruby-on-rails/
  def minimal_clean_address
    [:city,:zip_code,:country].to_a.compact.join(",")
  end

  def api_url
    "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false"
  end

  def api_query
    "#{api_url}&amp;address=#{minimal_clean_address}"
  end

  def geocode
    open(api_query) do |file|
      @body = file.read
      doc = Nokogiri::XML(@body)
      parse_response(doc)
    end
  end

  def parse_response(doc)
    self.error_code = (doc/:status).first.inner_html
    if error_code.eql? "OK"
      set_coordinates(doc)
      complete_address(doc)
    end
  end

  def set_coordinates(doc)
    self.latitude = (doc/:geometry/:location/:lat).first.inner_html
    self.longitude = (doc/:geometry/:location/:lng).first.inner_html
  end

  def complete_address(doc)
    (doc/:result/:address_component).each do |ac|
      if (ac/:type).first.inner_html == "sublocality"
        self.suburb = (ac/:long_name).first.inner_html
      end
      if (ac/:type).first.inner_html == "administrative_area_level_3"
        self.county = (ac/:long_name).first.inner_html
      end
      if (ac/:type).first.inner_html == "administrative_area_level_1"
        self.state = (ac/:long_name).first.inner_html
      end
    end
  end

  def geocode_with_cache
    c_address = address_lookup
    if c_address
      copy_cached_data(c_address)
    else
      geocode
    end
  end

  def address_lookup
    Address.where(cache_query).last
  end

  def cache_query
    ["streetno = ? AND street = ? AND city = ? and zipcode = ?",streetno,street,city,zipcode]
  end

  def copy_cached_data(ca)
    self.latitude = ca.latitude
    self.longitude = ca.longitude
    self.suburb = ca.suburb
    self.county = ca.county
    self.state = ca.state
  end
=end
end
