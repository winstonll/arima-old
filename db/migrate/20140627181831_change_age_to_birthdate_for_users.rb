class ChangeAgeToBirthdateForUsers < ActiveRecord::Migration
  def change
    remove_column :users, :age, :integer
    add_column :users, :bdate, :date

    add_index :users, :bdate
  end
end
