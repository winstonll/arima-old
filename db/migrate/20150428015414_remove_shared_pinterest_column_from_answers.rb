class RemoveSharedPinterestColumnFromAnswers < ActiveRecord::Migration
  def up
    remove_column :answers, :shared_pinterest
  end

  def down
    add_column :answers, :shared_pinterest, :boolean
  end
end
