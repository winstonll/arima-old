require 'csv'

FN_DATA_FILE_PATH = "lib/tasks/fix_names.csv"

namespace :arima do
  desc "Arima: Fix names"
  task :fix_names => :environment do
    i = 0
    CSV.foreach(FN_DATA_FILE_PATH, headers: :first_row, converters: :numeric) do |row|
      ActiveRecord::Base.transaction do

        i += 1 # for emails

        old_firstname = row[0]
        old_lastname = row[1]

        new_firstname = row[2]
        new_lastname = row[3]

        if old_lastname != new_lastname || old_firstname != new_firstname
          puts "Old names: #{old_firstname} #{old_lastname}"
          puts "New names: #{new_firstname} #{new_lastname}"

          old_email = "#{old_firstname.try(:downcase)}.#{old_lastname.try(:downcase)}#{i}@example.com"
          puts "Old email: #{old_email}"
          user = User.where(email: old_email).first

          if user.present?

            user.first_name = new_firstname unless user.first_name == new_firstname
            user.last_name = new_lastname unless user.last_name == new_lastname

            email = "#{new_firstname.try(:downcase)}.#{new_lastname.try(:downcase)}#{i}@example.com"
            puts "New email: #{email}"
            user.email = email

            user.save!

          end
        end

      end # transaction
    end # CSV
  end
end