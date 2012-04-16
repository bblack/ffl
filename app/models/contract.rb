class Contract < ActiveRecord::Base
  # Do not delete a contract! Nix it instead.

  belongs_to :player
  belongs_to :team, :include => :league
  validate :one_contract_per_player_per_league
  validates :player_id, :first_year, :value, :length, :presence => true
  validates_each :value do |model, att, value|
    model.errors.add(att, 'must be positive') if (value <= 0) rescue false
  end
  validate :cant_re_nix_or_re_start
  
  def active?
    !self.started_at.nil? and self.nixed_at.nil?
  end

  def cant_re_nix_or_re_start
    if self.id
      contract_in_db = Contract.find self.id
      unless contract_in_db.nixed_at.nil? or contract_in_db.nixed_at.to_time.eql?(self.nixed_at)
        errors.add(:nixed_at, "can't be changed after it's nixed")
      end
      unless contract_in_db.started_at.nil? or contract_in_db.started_at.to_time.eql?(self.started_at)
        errors.add(:started_at, "can't be changed after it's started")
      end
    end
  end

  def start(msg=nil)
    self.started_at = Time.now
    self.started_msg = msg
  end

  def nix(msg=nil)
    self.nixed_at = Time.now
    self.nix_message = msg
  end

  def one_contract_per_player_per_league
    league_active_contracts = self.team.league.active_contracts
      .where(:player_id => self.player_id)
      .where("contracts.id != ?", self.id)
    if self.active? and league_active_contracts.any?
      errors.add(:player_id, "cannot be the same as another contract in the same league")
    end
  end
  
end