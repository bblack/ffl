class RfaDecisionsController < ApplicationController
  before_filter :set_current_rfa_decision_period
  
  def set_current_rfa_decision_period
    if params[:rfa_decision_period_id]
      @rfa_decision_period = RfaDecisionPeriod.find(params[:rfa_decision_period_id])
    elsif params[:rfa_period_id]
      @rfa_decision_period = RfaPeriod.find(params[:rfa_period_id]).rfa_decision_period
    end
  end

  def create
    unless @rfa_decision_period.open?
      add_flash(:error, false, "The RFA decision period isn't currently open.")
      redirect_to :back and return
    end

    decision = RfaDecision.find_or_initialize_by_rfa_decision_period_id_and_player_id(
      @rfa_decision_period.id, params[:player_id])
    decision.update_attributes({
      :team_id => params[:team_id],
      :keep => params[:keep]
    })

    if decision.save
      add_flash(:notice, false, "Updated your decision on #{Player.find(params[:player_id]).full_name}: #{decision.keepstring}")
      redirect_to :back
    else
      decision.errors.each { |e| add_flash(:error, false, e)}
      redirect_to :back
    end
  end

end