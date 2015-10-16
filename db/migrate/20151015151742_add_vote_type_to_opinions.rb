class AddVoteTypeToOpinions < ActiveRecord::Migration
  def change
  	add_column :opinions, :vote_type, :string
  end
end