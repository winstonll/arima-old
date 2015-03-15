class AddGroupPageClassToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :page_class, :string
  end
end
