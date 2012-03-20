class TeamsController < ApplicationController

  def show
    @team = Team.includes(:league, :contracts => [:player]).find(params[:id])
    change_current_league(@team.league_id)
  end

end