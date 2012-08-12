class AddDraftIdToDraftNominations < ActiveRecord::Migration
  def self.up
    add_column :draft_nominations, :draft_id, :integer
  end

  def self.down
    remove_column :draft_nominations, :draft_id
  end
end
