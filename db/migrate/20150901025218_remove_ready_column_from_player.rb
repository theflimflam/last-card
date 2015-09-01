class RemoveReadyColumnFromPlayer < ActiveRecord::Migration
  def change
    remove_column :players, :ready
  end
end
