class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :label
      t.integer :question_id
      t.integer :counter

      t.timestamps
    end
  end
end
