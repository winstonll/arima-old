class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.integer :user_id
      t.integer :badge_id
      t.string :date

      t.timestamps
    end
  end
end
