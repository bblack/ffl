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

  # Helpers

  def find_players
    criteria = params.slice('last_name', 'first_name', 'nfl_team', 'position')
    criteria[:position] ||= League.positions
    # Use the rest of the criteria later
    @players = Player.where(:position => criteria[:position]).where("lower(last_name) like ?", "%#{(criteria[:last_name] || '').downcase}%")

  end

end
