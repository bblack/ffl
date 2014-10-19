class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :contracts
    drop_table :moves
    drop_table :move2s
    drop_table :transactions
    drop_table :transaction_comments
  end

  def down
  end
end
