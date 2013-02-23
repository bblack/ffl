class EspnStatsController < ApplicationController
  def player_points
    stats = EspnStat.where(params.slice(:player_id, :league_id, :season))
      .where('week is not null')
      .order('season asc, week asc')
    render :json => stats
  end

  def points_vs_pv
    change_current_league(params[:league_id])
    respond_to do |format|
      format.html do
        @chart_data_options = {
          league_id: @current_league.id,
          season: @current_league.season
        }
      end
      format.json do
        stats = Team.joins('left outer join leagues on teams.league_id = leagues.id')
          .joins('left outer join player_value_changes as pvcs on pvcs.team_id = teams.id')
          .joins('left outer join players on pvcs.player_id = players.id')
          .joins('left outer join espn_stats on players.espn_id = espn_stats.player_id')
          .group('pvcs.player_id', 'pvcs.id')
          .order('pvcs.created_at desc, espn_stats.points desc')
          .select([
            'players.first_name',
            'players.last_name',
            'players.nfl_team',
            'players.position',
            'espn_stats.points',
            'pvcs.new_value'])
          .where(
            'leagues.id' => params[:league_id],
            'espn_stats.season' => params[:season])
          .where('week is null')
        render :json => stats
      end
    end
  end
end