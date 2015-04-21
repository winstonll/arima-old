class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer "question_id"
      t.integer "user_id"
      t.string "vote_type"

      t.timestamps
    end
  end
end
