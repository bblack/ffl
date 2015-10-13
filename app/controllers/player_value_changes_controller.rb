class PlayerValueChangesController < ApplicationController
  def index
    change_current_league(params[:league_id])
    render :text => "No league selected" and return if @current_league.nil?
    rows = @current_league.players_pvcs
      .where('player_value_changes.new_value is not null')
      .includes(:player)
    respond_to do |format|
      format.csv do
        retval = "Player,Position,Team,Value,First year,Last year,Length\r\n"
        rows.each do |pvc|
          length = (pvc.last_year - pvc.first_year + 1) rescue nil
          retval += [
            pvc.player.name,
            pvc.player.position,
            pvc.player.nfl_team,
            pvc.new_value,
            pvc.first_year,
            pvc.last_year,
            length
          ].join(',') + "\r\n"
        end
        send_data retval, :type => 'application/csv', :filename => "#{@current_league.name}_#{Time.now.iso8601}.csv"
      end
      format.json do
        by_espn_id = {}
        rows.each do |pvc|
          by_espn_id[pvc.player.espn_id] = pvc.new_value
        end
        render json: {
          season: 2015,
          league_id: 172724,
          value_by_player_id: by_espn_id
        }
      end
    end
  end
end
