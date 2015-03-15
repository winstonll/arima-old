class AddSlugToQuestion < ActiveRecord::Migration
  def up
    add_column :questions, :slug, :string
    #create slugs for existing records
    Question.find_each(&:save)
  end

  def down
    remove_column :questions, :slug
  end
end
