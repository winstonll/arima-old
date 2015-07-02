class AddAnswerPlusToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :answer_plus, :boolean
  end
end
