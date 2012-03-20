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
    users_teams = Team.where(:league_id => @rfa_period.league_id, :owner_id => @current_user.id)
    if users_teams.count == 0
      add_flash :error, false, "You don't have a team in this league. Tell Brian about this."
      redirect_to :back
    elsif users_teams.count > 1
      add_flash :error, false, "You own more than one team in this league. Tell Brian about this."
      redirect_to :back
    end
    team = users_teams.first
    
    @bid = RfaBid.includes(:player).create(
      :rfa_period_id => @rfa_period.id,
      :player_id => params[:player_id],
      :team_id => team.id,
      :value => params[:value])
    if @bid.invalid?
      @bid.errors.each do |att, err|
        add_flash :error, false, "#{att} #{err}"
      end
    else
      add_flash :notice, false, "You bid #{@bid.value} on #{@bid.player.first_name} #{@bid.player.last_name}"
    end
    
    redirect_to :back
  end
  
end