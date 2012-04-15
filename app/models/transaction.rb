class Transaction < ActiveRecord::Base
  has_many :moves
  has_many :comments
  belongs_to :user
  belongs_to :league
  validates_associated :moves

  def complete!
    transaction do
      prev_completed_on = (Transaction.find(id).completed_on rescue nil)
      raise StandardError.new "Can't complete the transaction since it's already been completed" if prev_completed_on
      moves.each do |move|
        if move.old_contract_id
          move.old_contract.nix("Nixed with the completion of transaction ##{self.id}")
          move.old_contract.save!
          move.save!
        end
        if move.new_contract_id
          move.new_contract.start("Started with the complete of transaction ##{self.id}")
          move.new_contract.save!
          move.save!
        end
      end
      self.completed_on = Time.now
      self.save!
    end
  end

  def completed?
    !!completed_on
  end
end
