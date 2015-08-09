class PlayersController < ApplicationController

  def index
    find_players
    add_flash :warning, true, "No results matched your query" if @players.empty?
    respond_to do |format|
      format.html
      format.json {
        response.headers['x-total'] = Player.count.to_s
        render :json => @players.to_json
      }
    end
  end

  def show
    @player = Player.find(params[:id])
    respond_to do |format|
      format.html
      format.json {
        render :json => @player.to_json
      }
    end
  end

  # Helpers

  def find_players
    criteria = params.slice('last_name', 'first_name', 'nfl_team', 'position')
    @players = Player
      .order(:last_name, :first_name)
      .offset(params[:offset])
      .limit(params[:limit])
    @players = @players.where("lower(last_name) like ?", "%#{(criteria[:last_name] || '').downcase}%") if criteria[:last_name]
    @players = @players.where(:position => criteria[:position]) if criteria[:position]
  end

end
