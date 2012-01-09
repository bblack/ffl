class LeaguesController < ApplicationController
  
  def show
    league = League.where(:id => params[:id]).first

    if league.nil?
      session[:league_id] = nil
      add_warning "You are not browsing a league anymore"
    else
      session[:league_id] = league.id
      add_notice "You are now browsing league '#{league.name}'"
    end
    
    render :index
  end
  
end