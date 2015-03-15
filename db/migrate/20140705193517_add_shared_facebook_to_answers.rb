class AddSharedFacebookToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :shared_facebook, :bool
  end
end
