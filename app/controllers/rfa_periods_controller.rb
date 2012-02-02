class RfaPeriodsController < ApplicationController
  
  def show
    @rfaperiod = RfaPeriod.find params[:id]
    @bids = RfaBid.where(:rfa_period_id => @rfaperiod.id)
  end
  
end