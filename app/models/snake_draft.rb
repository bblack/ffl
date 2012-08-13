class SnakeDraft < Draft

  def current_team
    # First, what it would have been had no draft pick transactions occurred
    if current_pick[0].even?
      orig_team = teams_ordered[current_pick[1]]
    else
      orig_team = teams_ordered[teams_ordered.count - current_pick[1]]
    end

    # Then, what it is now after all that pick's trades happened
    last_transaction_for_pick = DraftPickTransaction.where(
      :draft_id => self.id,
      :orig_team => team.id,
      :round => current_pick[0])
      .includes(:team)
      .last

    if last_transaction_for_pick
      return last_transaction_for_pick.team
    else
      return orig_team
    end
  end

  def select!(team_id, player_id)
    dn = DraftNomination.create(
      :draft_id => id,
      :round => current_pick[0],
      :pick_in_round => current_pick[1],
      :team_id => team_id,
      :player_id => player_id)
    da = DraftAcquisition.create(
      :draft_nomination_id => dn.id,
      :team_id => team_id,
      :cost => 1)

    advance!
  end

end