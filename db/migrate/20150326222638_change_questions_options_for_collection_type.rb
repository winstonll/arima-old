class ChangeQuestionsOptionsForCollectionType < ActiveRecord::Migration
  def up
    change_column :questions, :options_for_collection, :text, :limit => nil
  end

  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :questions, :options_for_collection, :string
  end
end
