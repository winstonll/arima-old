class AddSharedPintrestToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :shared_pintrest, :bool
  end
end
