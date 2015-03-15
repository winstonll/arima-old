class AddLastLoginDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_login_date, :datetime
  end
end
