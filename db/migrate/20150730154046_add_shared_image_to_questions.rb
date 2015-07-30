class AddSharedImageToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :shared_image, :boolean
  end
end
