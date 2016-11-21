class RfaDecisionsController < ApplicationController
  before_filter :set_current_rfa_decision_period

  def set_current_rfa_decision_period
    if params[:rfa_decision_period_id]
      @rfa_decision_period = RfaDecisionPeriod.find(params[:rfa_decision_period_id])
    elsif params[:rfa_period_id]
      @rfa_decision_period = RfaPeriod.find(params[:rfa_period_id]).rfa_decision_period
    end

    change_current_league(@rfa_decision_period.rfa_period.league_id)
  end

  def create
    team = Team.where(league_id: @current_league.id, owner_id: @current_user.id).first
    decision = RfaDecision.find_or_initialize_by_rfa_decision_period_id_and_player_id(
      @rfa_decision_period.id, params[:player_id])
    # TODO: validate that team id is same as current owner
    decision.update_attributes(team_id: team.id, keep: params[:keep])
    result = "Updated your decision on #{Player.find(params[:player_id]).full_name}: #{decision.keepstring}"
    respond_to do |format|
      format.html do # TODO: remove
        add_flash(:notice, false, result)
        redirect_to :back
      end
      format.json do
        render json: {result: result}
      end
    end
  end

end
