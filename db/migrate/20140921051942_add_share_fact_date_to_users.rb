class AddShareFactDateToUsers < ActiveRecord::Migration
  def change
      add_column :users, :share_fact_date, :datetime
  end
end
