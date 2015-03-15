class FixSharePinterestColumnName < ActiveRecord::Migration
  def change
    rename_column :answers, :shared_pintrest, :shared_pinterest
  end
end
