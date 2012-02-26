class RfaPeriodsController < ApplicationController
  
  def show
    @rfaperiod = RfaPeriod.includes(:rfa_bids, :rfa_decision_period => [:rfa_decisions]).find(params[:id])
    @bids = @rfaperiod.rfa_bids.includes(:team).where(:rfa_period_id => @rfaperiod.id)
  end
  
end