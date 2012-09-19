class TeamsController < ApplicationController
  before_filter :load_team, :only => [:show, :espn_compare]

  def espn_compare
    render :json => @team.compare_to_espn
  end

  private

    def load_team
      @team = Team.includes(:league).find(params[:id]) # Include players when this becomes a proper association
      change_current_league(@team.league_id)
    end

end