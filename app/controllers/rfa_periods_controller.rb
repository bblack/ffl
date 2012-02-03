class RfaPeriodsController < ApplicationController
  
  def show
    @rfaperiod = RfaPeriod.includes(:rfa_bids).find(params[:id])
    @bids = @rfaperiod.rfa_bids.includes(:team).where(:rfa_period_id => @rfaperiod.id)
  end
  
end