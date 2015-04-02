class ChangeUserLatitudeTypeFloat < ActiveRecord::Migration
  execute("ALTER TABLE locations ALTER COLUMN latitude TYPE float USING (latitude::float)")
end
