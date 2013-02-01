class RfaDecision < ActiveRecord::Base
  belongs_to :team
  belongs_to :player
  belongs_to :rfa_decision_period
  validate :validate_team_has_player

  def validate_team_has_player
    contract = self.team.players_pvcs.where(:player_id => self.player_id)
    if contract.none?
      errors.add(:team_id, "must be the same as the team who owns this player's contract in this league.")
    end
  end

  def keepstring
    {true => 'keep', false => 'drop', nil => 'undecided'}[self.keep]
  end
end
