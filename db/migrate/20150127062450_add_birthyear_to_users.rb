class AddBirthyearToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birthyear, :integer
  end
end
