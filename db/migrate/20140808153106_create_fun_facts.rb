class CreateFunFacts < ActiveRecord::Migration
  def change
    create_table :fun_facts do |t|
      t.string :description

      t.timestamps
    end
  end
end
