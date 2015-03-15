class RemoveDescriptionAndAddMultipleChoiceOptionsToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :options_for_collection, :string
    remove_column :questions, :description, :text
  end
end
