class AddSlugToGroup < ActiveRecord::Migration
  def up
    add_column :groups, :slug, :string
    #create slugs for existing records
    Group.find_each(&:save)
  end

  def down
    remove_column :groups, :slug
  end
end
