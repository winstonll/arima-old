class AddLabelToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :label, :string
  end
end
