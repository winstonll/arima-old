require 'csv'

namespace :arima do
  desc "Arima: Import dummy users"
  task :import_dummy_users => :environment do
    i = 0
    CSV.foreach("lib/tasks/dummy.2500.csv", headers: :first_row, converters: :numeric) do |row|
      ActiveRecord::Base.transaction do

        i += 1 # for emails

        last_name = row[0]
        first_name = row[1]
        gender = row[2]
        age = row[3]
        dob = Time.now - age.years - rand(0..364).days
        email = "#{first_name.try(:downcase)}.#{last_name.try(:downcase)}#{i}@arima.io"
    
        user = User.create!(
          first_name: first_name,
          last_name: last_name,
          gender: gender,
          dob: dob,
          email: email,
          password: "arima123456!"
        )

        city = row[4]
        province = row[5]
        country = row[6]
        # assume that dummy users are only from these two countries
        country_code = 'US'
        country_code = 'CA' if country == 'Canada'

        location = Location.create!(
          user_id: user.id,
          city: city,
          province: province,
          country_code: country_code
        )

      end # transaction
    end # CSV
  end
end