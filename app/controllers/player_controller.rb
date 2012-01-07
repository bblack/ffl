class PlayerController < ApplicationController
  
  def search
    find_players
    @warnings << "No results matched your query" if @players.empty?
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
    criteria[:position] ||= ['QB', 'RB', 'WR', 'TE', 'Def', 'PK']
    # Use the rest of the criteria later
    @players = Player.where(:position => criteria[:position]).where("lower(last_name) like ?", "%#{criteria[:last_name]}%")

  end
  
end