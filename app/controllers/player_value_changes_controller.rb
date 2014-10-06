class PlayerValueChangesController < ApplicationController
  def index
    change_current_league(params[:league_id])
    render :text => "No league selected" and return if @current_league.nil?

    retval = "Player,Position,Team,Owner,Value,First year,Last year,Length\r\n"
    @current_league.teams.each do |team|
      team.players_pvcs.includes(:player).each do |pvc|
        length = (pvc.last_year - pvc.first_year + 1) rescue nil
        retval += [
          pvc.player.name,
          pvc.player.position,
          pvc.player.nfl_team,
          team.name,
          pvc.new_value,
          pvc.first_year,
          pvc.last_year,
          length
        ].join(',') + "\r\n"
      end
    end

    send_data retval, :type => 'application/csv', :filename => "#{@current_league.name}_#{Time.now.iso8601}.csv"
  end
end
