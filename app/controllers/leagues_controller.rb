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
  
end