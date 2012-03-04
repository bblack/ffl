class RfaPeriodsController < ApplicationController
  
  def set_current_team
  end

  def show
    @rfaperiod = RfaPeriod.includes(:league, :rfa_bids => [:team], :rfa_decision_period => [:rfa_decisions]).find(params[:id])
    @bids = @rfaperiod.rfa_bids

    if @current_user
      teams = Team.includes(:contracts).where(:owner_id => @current_user.id, :league_id => @rfaperiod.league_id)
      @current_team = teams.first if teams.one?
    end
  end
  
end