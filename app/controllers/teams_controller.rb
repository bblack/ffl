class TeamsController < ApplicationController
  before_filter :load_team, :except => [:index]

  def index
    change_current_league(params[:league_id])

    pvcs = @current_league.signed_players_pvcs.all
    rosters = EspnRosterSpot.where(:team_id => @current_league.team_ids).includes(:player).all.group_by(&:team_id)

    @rosters_by_pos = {}

    by_player = {}

    rosters.each do |tid, roster|
      roster.each do |spot|
        by_player[spot.player.id] = {spot: spot}
        @rosters_by_pos[tid] ||= {}
        @rosters_by_pos[tid][spot.player.position] ||= 0
        @rosters_by_pos[tid][spot.player.position] += 1
      end
    end

    pvcs.each do |pvc|
      by_player[pvc.player_id][:pvc] = pvc
    end

    @payrolls = {}

    by_player.each do |pid, stuff|
      @payrolls[stuff[:spot].team_id] ||= 0
      @payrolls[stuff[:spot].team_id] += (stuff[:pvc].new_value || 0)
    end
  end

  def fetch_espn
    raise StandardError.new("god mode req'd") if !god?
    @team.fetch_espn_roster
    add_flash(:notice, false, "Fetched the ESPN roster of team '#{@team.name}'")
    redirect_to team_path(@team)
  end

  def drop_and_zero_player
    # For dropping players in ffl when espn season hasn't opened yet
    raise StandardError.new("god mode req'd") if !god?
    player = Player.find(params[:player_id])
    EspnRosterSpot.where(
      :team_id => @team.id,
      :espn_player_id => player.espn_id
    ).destroy_all
    PlayerValueChange.create!(
      player_id: player.id,
      new_value: nil,
      league_id: @team.league_id,
      comment: 'drop_and_zero'
    )
    add_flash(:notice, false, "Dropped #{player.name} from #{@team.name}")
    redirect_to team_path(@team)
  end

  private

    def load_team
      @team = Team.includes(:league).find(params[:id]) # Include players when this becomes a proper association
      change_current_league(@team.league_id)
    end

end
