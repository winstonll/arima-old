require 'csv'

DATA_FILE_PATH = "lib/tasks/arima.v2c.csv"

STEP1 = true
STEP2 = true

namespace :arima do
  desc "Arima: Seed demo data step 1"
  task :seed_demo_data_1, [:limit] => :environment do |t, args|
    args.with_defaults(:limit => 20_000)
    
    # STEP 1
    if STEP1

      i = 0
      CSV.foreach(DATA_FILE_PATH, headers: :first_row, converters: :numeric) do |row|
        break if args.limit < i
        ActiveRecord::Base.transaction do

          i += 1
          head = row.to_hash.keys
          # puts "Headers: #{head}"

          # QUESTIONS

          if i == 1
            questions = head[10..34]
            puts "Questions: #{questions}"

            x = 0
            questions.each do |question|
              x += 1
              puts "Question #{x}: #{question}"

              # CREATE

              Question.create!(
                label: question
              )
            end
          end

          # USERS

          first_name = row[0]
          last_name = row[1]
          gender = row[2]
          age = row[3]
          birthdate = Time.now - age.years - rand(0..364).days
          email = "#{first_name.try(:downcase)}.#{last_name.try(:downcase)}#{i}@example.com"

          # puts "First name: #{first_name}. Last name: #{last_name}. Email: #{email}." \
          #     " Gender: #{gender}. Age: #{age}."

          # CREATE

          user = User.create!(
            first_name: first_name,
            last_name: last_name,
            gender: gender,
            dob: birthdate,
            email: email,
            password: "arima123456!"
          )

          # LOCATION

          city = row[4]
          province = row[5]
          country_code = row[6]

          # puts "City: #{city}. Province: #{province}. Country: #{country_obj}."

          # CREATE

          location = Location.create!(
            user_id: user.id,
            city: city,
            province: province,
            country_code: country_code
          )

        end
      end

      # GROUPS

      groups = [
        "Money <br>Matters",
        "Health <br>+ Fitness",
        "Education <br>+ Knowledge",
        "Entertainment <br>+ Gadgets",
        "Work <br>+ Business"
      ]

      # CREATE

      groups.each do |group|
        Group.create!(label: group)
      end

    end # step 1
  end

  # STEP 2
  desc "Arima: Seed demo data step 2"
  task :seed_demo_data_2, [:limit] => :environment do |t, args|
    args.with_defaults(:limit => 20_000)

    if STEP2

      CSV.foreach(DATA_FILE_PATH, headers: :first_row, converters: :numeric) do |row|
        break if args.limit < $.

        head = row.to_hash.keys

        # ANSWERS

        @answers            = row.fields[10..34] # 25 answers
        @questions        ||= head[10..34] # 25 questions
        @questions_stored ||= Question.all
        @users_stored     ||= User.all

        question_answer = {}
        @answers.each_with_index do |a, i|
          q = @questions[i].to_s
          question_answer[q] = a
          qs = @questions_stored.detect{ |qs| qs["label"] == q }

          first_name = row[0]
          last_name = row[1]
          us = @users_stored.detect{ |us| us["first_name"] == first_name && us["last_name"] == last_name }

          puts "Answers - question_id: #{qs.id}, user_id: #{us.id}, value: #{a}"

          # CREATE

          Answer.create!(question_id: qs.id, user_id: us.id, value: a) if a.present?
        end
      end

    end # step 2
  end
end