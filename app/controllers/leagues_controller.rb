class LeaguesController < ApplicationController
  
  def show
    change_current_league(params[:id])
  end
  
end