class AddQuestionIdToOpinions < ActiveRecord::Migration
  def change
    add_column :opinions, :question_id, :integer
  end
end
