class RfaBidsController < ApplicationController
  before_filter :set_current_rfa_period

  def set_current_rfa_period
    @rfa_period = params[:rfa_period_id] ? RfaPeriod.find(params[:rfa_period_id]) : nil
    change_current_league(@rfa_period.league_id)
  end

  def index
    bids = RfaBid.includes(:team).order("created_at DESC").limit(10).where(:rfa_period_id => params[:rfa_period_id])
    render :json => bids.to_json(:include => [:team, :player])
  end

  def create
    team = @rfa_period.league.teams.where(owner_id: @current_user.id).first
    errors = []
    @bid = RfaBid.includes(:player).create(
      :rfa_period_id => @rfa_period.id,
      :player_id => params[:player_id],
      :team_id => team.id,
      :value => params[:value])
    if @bid.invalid?
      errors = @bid.errors.full_messages
    else
      result = "You bid #{@bid.value} on #{@bid.player.first_name} #{@bid.player.last_name}"
    end

    respond_to do |format|
      format.html do # TODO: remove
        if errors.any?
          errors.each {|err| add_flash :error, false, err}
        else
          add_flash :notice, false, result
        end
        redirect_to :back
      end
      format.json do
        puts "rendering json..."
        status = errors.any? ? 400 : 200
        render status: status, json: {errors: errors, result: result}
      end
    end
  end

end
