class AddReadyFlagToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :ready, :boolean, default: false, null: false
  end
end
