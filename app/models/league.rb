class League < ActiveRecord::Base
  has_many :teams
  has_many :contracts, :through => :teams
  
  def get_contract_for_player(player)
    team_ids = self.teams.collect { |t| t.id }
    contracts = Contract.where(:player_id => player.id, :team_id => team_ids)
    raise "Huh, there's more than one contract in this league for this player" if contracts.count > 1
    return contracts.first
  end
end
