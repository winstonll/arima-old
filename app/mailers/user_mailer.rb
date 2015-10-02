class UserMailer < ActionMailer::Base
    default from: "info@arima.com"

  def signup_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Arima!')
  end

  def forgot_password_email(user)
    @user = user
    mail(to: @user.email, subject: 'Reset your password')
  end

  def inactive_email(user)
    update_last_emailed_at(user)
    mail(to: user.email, subject: "We miss you!")
  end

  def signup_admin(admin, user)
    @admin = admin
    @user = user
    mail(to: admin.email, subject: "alert!")
  end

  def signup_modal_admin(admin, user)
    @admin = admin
    @user = user
    mail(to: admin.email, subject: "alert!")
  end

  def submit_question_email(user, submit_question_data)
    @user                 = user
    @question_name        = submit_question_data.title
    @question_category    = submit_question_data.category
    @question_answer_type = submit_question_data.answer_type
    @question_answers     = submit_question_data.answers.split
    @wants_subscription   = submit_question_data.wants_subscription
    @admin_url            = 'http://arima.io/admin'
    # mail(to: 'winstonbcom.li@mail.utoronto.ca', subject: 'New Question Suggestion!')
  end

  def user_submission_accepted_email(user, submitted_question_data)
    @user                 = user
    @question_name        = submit_question_data.title
    @wants_subscription   = submit_question_data.wants_subscription
    @points_for_approval  = 5
    mail(to: '#{user.email}', subject: 'Congrats, your question got approved!')
  end

  def referred_user_email(user_who_referred, user_who_signed_up)
    @registered_user     = user_who_referred
    @new_user            = user_who_signed_up
    @points_for_referral = 5
    mail(to: @registered_user.email, subject: "Congrats! You\ve gained <%= @points_for_referral %> points!")
  end

  protected
    def update_last_emailed_at(user)
      user.last_emailed_at = Time.now
      user.save
    end
end
