class AddValueTypeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :value_type, :string
  end
end
