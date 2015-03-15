class ChangeValueInAnwsers < ActiveRecord::Migration
  def change
    change_column :answers, :value, :text
  end
end
