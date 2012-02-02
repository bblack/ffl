class RfaBidsController < ApplicationController
  
  def create
    RfaBid.create  :rfa_period_id => params[:rfa_period]
  end
  
end