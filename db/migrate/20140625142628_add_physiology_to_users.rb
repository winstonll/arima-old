class AddPhysiologyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :gender, :string
    add_column :users, :age, :integer
    drop_table :physiologies
  end
  
  def down
    raise AcitveRecord::IrreversibleMigration
  end
end
