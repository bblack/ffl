module MovesHelper
  def main_team_for(move)
    if move.add? or move.trade?
      main_team = move.new_contract.team
    elsif move.drop?
      main_team = move.old_contract.team
    else
      raise StandardError.new("move #{move.id} has invalid type")
    end

    raise StandardError.new(move.to_json) if main_team.nil?
    return main_team
  end

  def description_for(move)
    if move.add?
      "#{move.new_contract.team.name} adds #{move.new_contract.player.full_name}"
    elsif move.drop?
      "#{move.old_contract.team.name} drops #{move.old_contract.player.full_name}"
    elsif move.trade?
      "#{move.new_contract.team.name} acquires #{move.new_contract.player.full_name} from #{move.old_contract.team.name}"
    end
  end
end