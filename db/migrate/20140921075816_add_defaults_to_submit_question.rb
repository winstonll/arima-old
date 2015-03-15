class AddDefaultsToSubmitQuestion < ActiveRecord::Migration
  def change
    change_column :submit_questions, :title, :string, null: false
    change_column :submit_questions, :answers, :text, null: false
    change_column :submit_questions, :answer_type, :string, null: false
    change_column :submit_questions, :category, :string, null: false
    change_column :submit_questions, :approved, :boolean, null: false, default: false
  end
end
