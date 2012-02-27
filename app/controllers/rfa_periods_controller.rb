class RfaPeriodsController < ApplicationController
  
  def set_current_team
  end

  def show
    @rfaperiod = RfaPeriod.includes(:rfa_bids, :rfa_decision_period => [:rfa_decisions]).find(params[:id])
    @bids = @rfaperiod.rfa_bids.includes(:team).where(:rfa_period_id => @rfaperiod.id)

    if @current_user
      teams = Team.where(:owner_id => @current_user.id, :league_id => @rfaperiod.league_id)
      @current_team = teams.first if teams.one?
    end
  end
  
end