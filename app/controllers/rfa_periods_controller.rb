class RfaPeriodsController < ApplicationController
  before_filter :set_members

  def show

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
        teams = Team.includes(:contracts).where(:owner_id => @current_user.id, :league_id => @rfaperiod.league_id)
        @current_team = teams.first if teams.one?
      end
    end
  
end