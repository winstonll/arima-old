class InitialSchema < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.string :province
      t.string :country
      t.string :continent
      t.string :lat_lng

      t.timestamps
    end

    create_table :physiologies do |t|
      t.integer :user_id
      t.string :gender
      t.string :height
      t.string :weight
      t.string :shoe_size

      t.timestamps
    end

    create_table :groups do |t|
      t.string :label

      t.timestamps
    end

    create_table :questions do |t|
      t.string :label
      t.text :description

      t.timestamps
    end

    create_table :answers do |t|
      t.integer :user_id
      t.integer :question_id
      t.string :value
      t.string :value_type

      t.timestamps
    end

    create_table :groups_questions do |t|
      t.integer :group_id
      t.integer :question_id

      t.timestamps
    end
  end
end
