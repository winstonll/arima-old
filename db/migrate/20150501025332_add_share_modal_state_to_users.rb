class AddShareModalStateToUsers < ActiveRecord::Migration
  def up
    add_column :users, :share_modal_state, :string, :default => "show"
  end

  def down
    remove_column :users, :share_modal_state
  end
end
