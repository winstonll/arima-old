class CreateOpinions < ActiveRecord::Migration
  def change
    create_table :opinions do |t|
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
