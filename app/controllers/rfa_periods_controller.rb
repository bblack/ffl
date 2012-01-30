class RfaPeriodsController < ApplicationController
  
  def show
    @rfaperiod = RfaPeriod.find params[:id]
  end
  
end