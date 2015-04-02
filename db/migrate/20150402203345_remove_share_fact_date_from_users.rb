class RemoveShareFactDateFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :share_fact_date, :datetime
  end
end
