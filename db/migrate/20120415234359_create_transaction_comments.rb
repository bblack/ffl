class CreateTransactionComments < ActiveRecord::Migration
  def self.up
    create_table :transaction_comments do |t|
      t.integer :transaction_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :transaction_comments
  end
end
