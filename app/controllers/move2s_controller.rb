class Move2sController < ApplicationController
  def create
    m = Move2.new(params.slice(:player_id, :new_team_id, :league_id, :new_pv, :final_year))
    last_move = Move2.where(params.slice(:player_id, :league_id)).order(:id).last
    if last_move
      m.old_team_id = last_move.new_team_id
    else
      m.new_pv = params[:new_pv] || 1
      m.final_year = params[:final_year] || Date.today.year
    end
    
    m.save!

    redirect_to :back
  end
end