namespace :arima do
  desc "Fix the missing location issue for the admin user model page"
  task admin_panel_user_fix: :environment do

    users_to_fix_emails = User.all.to_a.select { |u| u.location.nil? }.collect { |u| u.email }

    users_to_fix_emails.each do |e|
      loc = Location.new(country_code: "CA") # Assume that they are canadian as a temp fix
      u = User.find_by(email: e)
      u.location = loc
      puts "fix failed for user #{u.email}" unless u.save
    end

    puts "Total number of users who had the error: #{users_to_fix_emails.size}"
  end

  task email_inactive_users: :environment do
    inactive_users = User.where('current_sign_in_at IS NOT NULL AND current_sign_in_at < ? AND last_emailed_at < ?', Time.now - 1.month.to_i, Time.now - 1.week.to_i )

    inactive_users.each do |u|
      UserMailer.inactive_email(@user).deliver!
    end

    puts "Total number of users emailed was #{inactive_users.size}"

  end

  task calculate_rank: :environment do
    arr = User.order('points DESC')
    counter = 1
    arr.each do |user|
      user.rank = counter
      counter = counter + 1
      user.save
    end
  end

end
