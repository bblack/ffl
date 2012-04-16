class Move < ActiveRecord::Base
  belongs_to :transaction
  belongs_to :old_contract, :class_name => 'Contract', :foreign_key => 'old_contract_id'
  belongs_to :new_contract, :class_name => 'Contract', :foreign_key => 'new_contract_id'
  # Validating contracts is e.g. to ensure that nobody has signed a player on this move
  # since this move was created
  #validates_associated :old_contract
  #validates_associated :new_contract
  validate :old_and_new_must_have_same_player
  validate :old_and_new_must_have_same_league
  validate :no_other_move_may_have_same_player
  validate :cant_save_after_transaction_completed
  validate :contracts_belong_to_league
  validate :contracts_validate
  before_destroy :cant_destroy_after_transaction_completed

  def contracts_validate
    [:old_contract, :new_contract].each do |c|
      contract = self.send(c)
      if contract.invalid?
        contracs.errors.each do |contract_att, error_arr|
          error_arr.each do |e|
            self.errors[:base] << "#{c} #{contract_att} #{e}"
          end
        end
      end
    end
  end

  def contracts_belong_to_league
    if new_contract_id and new_contract.team.league_id != transaction.league_id
      errors.add(:new_contract, "must belong to the same league as the transaction")
    end
    if old_contract_id and old_contract.team.league_id != transaction.league_id
      errors.add(:old_contract, "must belong to the same league as the transaction")
    end
  end

  def cant_destroy_after_transaction_completed
    raise StandardError.new("Can't destroy move after its transaction is complete") if self.transaction.completed?
  end

  def cant_save_after_transaction_completed
    errors[:base] << "Can't save move after its transaction is complete" if self.transaction.completed?
  end

  def old_and_new_must_have_same_player
    if trade? and old_contract.player_id != new_contract.player_id
      errors.add(:old_contract, "must be for the same player as new_contract")
    end
  end

  def old_and_new_must_have_same_league
    if trade? and old_contract.team.league_id != new_contract.team.league_id
      errors.add(:old_contract, "must be in the same league as new_contract")
    end
  end

  def no_other_move_may_have_same_player
    other_moves = Move.includes(:old_contract, :new_contract).where(:transaction_id => self.transaction_id)
    other_moves = other_moves.where("id <> ?", self.id) unless self.id.nil?
    pids = []
    pids << new_contract.player_id if new_contract
    pids << old_contract.player_id if old_contract
    moves_matching_any_pids = other_moves.select{|m| (m.old_contract and pids.any?{|p| m.old_contract.player_id == p}) or (m.new_contract and pids.any?{|p| m.new_contract.player_id == p}) }
    if moves_matching_any_pids.any?
      errors.add(:move, "can't be associated with a player that another move in this transaction is already associated with")
    end
  end

  def trade?
    old_contract_id and new_contract_id
  end

  def drop?
    old_contract_id and not new_contract_id
  end

  def add?
    new_contract_id and not old_contract_id
  end

end
