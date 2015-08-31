class AddReadyFlagToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :ready, :boolean, null: false, default: false
  end
end
