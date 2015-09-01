class RemoveRoundCounterFromGame < ActiveRecord::Migration
  def change
    remove_column :games, :round_counter
  end
end
