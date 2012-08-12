class CreateDraftAcquisitions < ActiveRecord::Migration
  def self.up
    create_table :draft_acquisitions do |t|
      t.integer :draft_nomination_id
      t.integer :team_id
      t.integer :cost

      t.timestamps
    end
  end

  def self.down
    drop_table :draft_acquisitions
  end
end
