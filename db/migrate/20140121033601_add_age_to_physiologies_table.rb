class AddAgeToPhysiologiesTable < ActiveRecord::Migration
  def change
    add_column :physiologies, :age, :integer
  end
end
