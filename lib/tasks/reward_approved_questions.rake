namespace :arima do
  desc "Arima: Award and email all users who have submitted questions that have been approved for use."
  task :reward_approved_questions => :environment do
    SubmitQuestion.all.where(:approved => true).each do |submitted_question|
      approved_user = User.find(submitted_question.user_id)
      approved_user.points += 5
      UserMailer.user_submission_accepted_email(approved_user, submitted_question).deliver!
    end
  end
end