class CreateSubmitQuestions < ActiveRecord::Migration
  def change
    create_table :submit_questions do |t|
      t.text :title
      t.string :category
      t.string :answer_type
      t.string :answers
      t.boolean :approved

      t.timestamps
    end
  end
end
