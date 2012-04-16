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

    errors.add(:nixed_at, "can't be changed after it's nixed") if nixed_at_was != nil and nixed_at_changed?
    errors.add(:started_at, "can't be changed after it's started") if started_at_was != nil and started_at_changed?
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