class CorrectSubmitQuestionField < ActiveRecord::Migration
  def change
    remove_column :submit_questions, :wants_subsciption, :boolean
    add_column :submit_questions, :wants_subscription, :boolean
  end
end
