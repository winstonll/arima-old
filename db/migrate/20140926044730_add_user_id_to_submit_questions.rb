class AddUserIdToSubmitQuestions < ActiveRecord::Migration
  def change
    add_column :submit_questions, :user_id, :integer
  end
end
