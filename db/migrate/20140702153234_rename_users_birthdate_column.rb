class RenameUsersBirthdateColumn < ActiveRecord::Migration
  def change
    rename_column :users, :bdate, :dob
  end
end
