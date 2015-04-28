class RemoveSharedFactDateFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :share_fact_date
  end

  def down
    add_column :users, :share_fact_date, :string
  end
end
