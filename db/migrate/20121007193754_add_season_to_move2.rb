class AddSeasonToMove2 < ActiveRecord::Migration
  def self.up
    add_column :move2s, :season, :integer
  end

  def self.down
    remove_column :move2s, :season
  end
end
