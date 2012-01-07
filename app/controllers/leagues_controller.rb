class LeaguesController < ApplicationController
  
  def choose
    league = League.find(params[:id]) if params[:id]
    if league
      session[:league_id] = league.id
      @league = league
      @notices << "You are now on league '#{@league.name}'"
    end
  end
  
end