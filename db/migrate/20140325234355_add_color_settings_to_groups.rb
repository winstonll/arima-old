class AddColorSettingsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :background_color, :string
    add_column :groups, :text_color, :string
  end
end
