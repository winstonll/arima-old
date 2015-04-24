class AddVotecountToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :votecount, :integer, default: 0
  end
end
