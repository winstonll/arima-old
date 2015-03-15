class AddWantsSubscriptionToSubmitQuestions < ActiveRecord::Migration
  def change
    add_column :submit_questions, :wants_subsciption, :boolean
  end
end
