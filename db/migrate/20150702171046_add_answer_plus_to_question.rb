class AddAnswerPlusToQuestion < ActiveRecord::Migration
  def change
    remove_column :questions, :answer_plus, :boolean
  end
end
