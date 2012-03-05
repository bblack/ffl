class TeamsController < ApplicationController

  def show
    @team = Team.includes(:league, :contracts => [:player]).find(params[:id])
  end

end