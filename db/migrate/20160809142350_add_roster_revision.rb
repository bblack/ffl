class AddRosterRevision < ActiveRecord::Migration
  def up
    add_column :espn_roster_spots, :roster_revision, :uuid
    add_column :leagues, :roster_revision, :uuid
    drop_column :teams, :espn_roster_last_updated
  end

  def down
    remove_column :espn_roster_spots, :roster_revision
    remove_column :leagues, :roster_revision
    add_column :teams, :espn_roster_last_updated, :datetime
  end
end
