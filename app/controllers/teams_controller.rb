class TeamsController < ApplicationController
  before_filter :load_team, :except => [:index]

  def fetch_espn
    @team.fetch_espn_roster
    add_flash(:notice, false, "Fetched the ESPN roster of team '#{@team.name}'")
    redirect_to team_path(@team)
  end

  private

    def load_team
      @team = Team.includes(:league).find(params[:id]) # Include players when this becomes a proper association
      change_current_league(@team.league_id)
    end

end