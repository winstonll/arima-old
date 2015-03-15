class ChangeUuidToUsernameForUsers < ActiveRecord::Migration
  def up
    remove_column :users, :uuid
    add_column :users, :username, :string

    add_index :users, :username, :unique => true
  end
  
  def down
    raise AcitveRecord::IrreversibleMigration
  end
end
