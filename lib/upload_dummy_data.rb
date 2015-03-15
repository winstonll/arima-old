require 'csv'

class UploadDummyData

  attr_accessor :data, :flash_alert, :flash_notice

  def process!
    i = 0
    question = nil # save this for later
    qs = nil # question object

    ActiveRecord::Base.transaction do

      CSV.foreach(data, headers: :first_row, converters: :numeric) do |row|
        # puts row

        i += 1 # increment counter

        last_name = row[0]
        first_name = row[1]

        answer = row[2]

        # get the question from the headers
        headers = row.to_hash.keys
        question = headers[2]

        # make email from names
        # this has to be the same algo as in the import_seed_data.rake file
        email = "#{first_name.try(:downcase)}.#{last_name.try(:downcase)}#{i}@arima.io"

        # create question only on first run
        if i == 1 && question
          # puts "Question: #{question}"

          begin
            qs = Question.create!(label: question)
          rescue Exception => e
            self.flash_alert = e.message
            raise ActiveRecord::Rollback
            return false
          end
        end

        if qs && answer
          # find user by munged email from first and last name
          begin
            # puts "Email: #{email}"
            user = User.find_by_email(email)
            # raise exeption if user is not found
            raise Exception.new("Can't find user by email `#{email}`!") unless user
          rescue Exception => e
            self.flash_alert = e.message
            raise ActiveRecord::Rollback
            return false
          end

          # create a new answer for each user
          # puts "Answers - question_id: #{qs.id}, user_id: #{user.id}, value: #{answer}"
          begin
            Answer.create!(question_id: qs.id, user_id: user.id, value: answer)
          rescue Exception => e
            self.flash_alert = e.message
            raise ActiveRecord::Rollback
            return false
          end
        end

      end

    end # transaction

    self.flash_notice = "Question and answers processed successfully!"
    return true unless self.flash_alert
  end

end