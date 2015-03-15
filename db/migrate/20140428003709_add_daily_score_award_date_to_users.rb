class AddDailyScoreAwardDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_score_award_date, :date
  end
end
