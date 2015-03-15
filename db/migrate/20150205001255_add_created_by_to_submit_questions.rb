class AddCreatedByToSubmitQuestions < ActiveRecord::Migration
  def change
    add_column :submit_questions, :created_by, :text
  end
end
