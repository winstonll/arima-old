class AddIndexes < ActiveRecord::Migration
  def change
    add_index :answers, :user_id
    add_index :answers, :question_id

    add_index :groups_questions, :group_id
    add_index :groups_questions, :question_id

    add_index :locations, :city
    add_index :locations, :country_code
    add_index :locations, :user_id

    add_index :physiologies, :user_id
    add_index :physiologies, :gender
    add_index :physiologies, :age

    add_index :users, :uuid
  end
end
