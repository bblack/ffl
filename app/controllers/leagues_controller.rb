class LeaguesController < ApplicationController

  def show
    change_current_league(params[:id])
  end

  def draft_form
  	change_current_league(params[:id])
  end

  def draft
  	change_current_league(params[:id])
  	render :json => @current_league.draft(params[:picks])
  end

  def update_espn_rosters
    change_current_league(params[:id])
    @current_league.update_espn_rosters
    add_flash(:notice, false, 'ESPN rosters updated.')
    redirect_to league_url(@current_league)
  end
end
