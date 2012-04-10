class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :transaction_id
      t.integer :old_contract_id
      t.integer :new_contract_id

      t.timestamps
    end
  end

  def self.down
    drop_table :moves
  end
end
