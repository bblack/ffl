class LeaguesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: League.all }
    end
  end

  def show
    change_current_league(params[:id])
    respond_to do |format|
      format.html { redirect_to league_teams_path(@current_league) }
      format.json { render json: @current_league }
    end
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
    respond_to do |format|
      format.html do
        add_flash(:notice, false, 'ESPN rosters updated.')
        redirect_to league_url(@current_league)
      end
      format.json {render status: 200, json: ''}
    end
  end
end
