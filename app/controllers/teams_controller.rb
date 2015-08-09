class TeamsController < ApplicationController
  before_filter :load_team, :except => [:index]

  def index
    change_current_league(params[:league_id])

    pvcs = @current_league.signed_players_pvcs.all
    rosters = EspnRosterSpot
      .where(roster_revision: @current_league.roster_revision)
      .where('roster_revision is not null')
      .includes(:player).all
      .group_by(&:team_id)
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

    respond_to do |format|
      format.html
      format.json do
        teams = @current_league.teams.map(&:serializable_hash).index_by{|t| t['id']}
        @payrolls.each{|tid, payroll| teams[tid]['payroll'] = payroll}
        @rosters_by_pos.each{|tid, roster| teams[tid]['roster'] = roster}
        render json: teams.values.sort_by{|x| x['id']}
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @team.to_json(:include => [:owner], :methods => [:payroll, :payroll_available] ) }
    end
  end

  def roster
    pvcs = roster_pvcs(@team)
    render json: pvcs.to_json(:include => :player)
  end

  def fetch_espn
    raise StandardError.new("god mode req'd") if !god?
    @team.fetch_espn_roster
    respond_to do |format|
      format.html do
        add_flash(:notice, false, "Fetched the ESPN roster of team '#{@team.name}'")
        redirect_to team_path(@team)
      end
      format.json do
        render json: roster_pvcs(@team).to_json(:include => :player)
      end
    end
  end

  # TODO: REMOVE THIS
  def drop_and_zero_player
    # For dropping players in ffl when espn season hasn't opened yet
    raise StandardError.new("god mode req'd") if !god?
    player = Player.find(params[:player_id])
    EspnRosterSpot.where(
      :roster_revision => @current_league.roster_revision,
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

    def roster_pvcs(team)
      players = team.players.index_by(&:id)
      pvcs = team.players_pvcs.includes(:player)
      pvcs.each {|c| c.player = players[c.player_id]}
      return pvcs
    end

end
