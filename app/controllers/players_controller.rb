class PlayersController < ApplicationController
  
  def index
    find_players
    add_flash :warning, true, "No results matched your query" if @players.empty?
    respond_to do |format|
      format.html
      format.json {
        render :json => @players.to_json
      }
    end
  end

  def show
    @player = Player.find(params[:id])
    @chart_data_options = {
      player_id: @player.espn_id,
      league_id: @current_league.espn_id,
      season: @current_league.season
    }
  end
  
  # Helpers
  
  def find_players
    criteria = params.slice('last_name', 'first_name', 'nfl_team', 'position')
    criteria[:position] ||= ['QB', 'RB', 'WR', 'TE', 'Def', 'PK']
    # Use the rest of the criteria later
    @players = Player.where(:position => criteria[:position]).where("lower(last_name) like ?", "%#{(criteria[:last_name] || '').downcase}%")
  end
  
end