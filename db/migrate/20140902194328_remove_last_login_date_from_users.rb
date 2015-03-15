class RemoveLastLoginDateFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_login_date, :datetime
  end
end
