class RfaPeriodsController < ApplicationController
  before_filter :set_members

  def show
    respond_to do |format|
      format.html # TODO: REMOVE
      format.json do
        # TODO: make this less crappy
        contracts = @rfaperiod.contracts_eligible.as_json(include: :player)
        spots = EspnRosterSpot.where(roster_revision: @rfaperiod.league.roster_revision)
        contracts.each do |c|
          c['team_id'] = spots.find{|s| s.espn_player_id == c[:player]['espn_id']}.team_id
        end
        res_object = @rfaperiod.as_json(
          include: {
            :rfa_bids => {},
            :rfa_decision_period => {
              include: :rfa_decisions
            }
          },
          methods: :open?
          )
          .merge(contracts_eligible: contracts)
        if res_object[:rfa_decision_period] && @current_team
          res_object[:rfa_decision_period][:_tentative_payroll] =
            @rfaperiod.rfa_decision_period.tentative_payroll_for_team(@current_team.id)
        end
        res_object[:teams] = @rfaperiod.league.teams.map do |team|
          {
            id: team.id,
            name: team.name,
            max_bid_allowed: team.max_rfa_bid(@rfaperiod.id)
          }
        end
        render json: res_object
      end
    end
  end

  def bigredbutton
    @bigredbutton_results = @rfaperiod.bigredbutton(dryrun=false)
    #render :json => @bigredbutton_results
  end

  private

    def set_members
      @rfaperiod = RfaPeriod.includes(:league, :rfa_bids => [:team], :rfa_decision_period => [:rfa_decisions]).find(params[:id])
      @bids = @rfaperiod.rfa_bids
      change_current_league(@rfaperiod.league_id)

      if @current_user
        teams = Team.where(:owner_id => @current_user.id, :league_id => @rfaperiod.league_id)
        @current_team = teams.first if teams.one?
      end
    end

end
