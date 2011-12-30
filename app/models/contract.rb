class Contract < ActiveRecord::Base
  belongs_to :player
  belongs_to :team, :include => :league
  
end

class ContractValidator < ActiveModel::Validator
  def validate(record)
    player = record.player
    league = record.team.league
    team_ids_on_league = Team.where :league_id => league.id
    existing_contracts = Contract.where :player_id => player.id, :team_id => team_ids_on_league
    existing_contracts.each do |contract|
      if contract.id != record.id
        errors[:team] << "Must belong to a league for which this player doesn't already have a contract"
      end
    end
  end
end