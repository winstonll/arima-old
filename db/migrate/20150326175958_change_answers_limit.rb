class ChangeAnswersLimit < ActiveRecord::Migration
  def up
    change_column :answers, :value, :text, :limit => nil
  end

  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :answers, :value, :text
  end
end
