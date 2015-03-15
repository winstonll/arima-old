class AddSharedTwitterToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :shared_twitter, :bool
  end
end
