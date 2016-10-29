class LeaguesController < ApplicationController
  def index
    respond_to do |format|
      format.html { redirect_to '/app/leagues' }
      format.json { render json: League.all }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to "/app/leagues/#{params[:id]}" }
      format.json do
        change_current_league(params[:id])
        render json: @current_league
      end
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
