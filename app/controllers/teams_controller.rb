class TeamsController < ApplicationController
  before_filter :load_team, :except => [:index]

  def index
    change_current_league(params[:league_id])
  end

  def fetch_espn
    raise StandardError.new("god mode req'd") if !god?
    @team.fetch_espn_roster
    add_flash(:notice, false, "Fetched the ESPN roster of team '#{@team.name}'")
    redirect_to team_path(@team)
  end

  def drop_player
    # For dropping players in ffl when espn season hasn't opened yet
    player = Player.find(params[:player_id])
    EspnRosterSpot.where(
      :team_id => @team.id,
      :espn_player_id => player.espn_id
    ).destroy_all
    add_flash(:notice, false, "Dropped #{player.name} from #{@team.name}")
    redirect_to team_path(@team)
  end

  private

    def load_team
      @team = Team.includes(:league).find(params[:id]) # Include players when this becomes a proper association
      change_current_league(@team.league_id)
    end

end
