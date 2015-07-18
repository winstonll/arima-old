class AddImageLinkToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :image_link, :string
  end
end
