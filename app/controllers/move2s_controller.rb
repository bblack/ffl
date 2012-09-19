class Move2sController < ApplicationController
  def create
    m = Move2.new(params.slice(:player_id, :new_team_id, :league_id, :new_pv))
    last_move = Move2.where(params.slice(:player_id, :league_id)).order(:id).last
    m.old_team_id = last_move ? last_move.new_team_id : nil
    m.save!

    redirect_to :back
  end
end