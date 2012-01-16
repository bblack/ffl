class Contract < ActiveRecord::Base
  belongs_to :player
  belongs_to :team, :include => :league
  validate :one_contract_per_player_per_league
  validates :player_id, :first_year, :value, :length, :presence => true
  validates_each :value do |model, att, value|
    model.errors.add(att, 'must be positive') if value <= 0
  end
  
  def one_contract_per_player_per_league
    team_ids_on_league = Team.where :league_id => self.team.league.id
    existing_contracts = Contract.where :player_id => self.player.id, :team_id => team_ids_on_league
    existing_contracts.each do |contract|
      if contract.id != self.id
        errors.add(:player_id, "cannot be the same as another contract in the same league")
      end
    end
  end
  
end