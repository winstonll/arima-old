# Documentation: http://github.com/javan/whenever

# Award points to users with approved submitted questions
every 1.day do
  rake "arima:reward_approved_questions"
end

# Email users who have been inactive for
every :day, at: '12pm' do
	rake "arima:email_inactive_users"
end

#every 1.day, :at => '12:00 pm' do
#  rake "arima:calculate_rank"
#end
