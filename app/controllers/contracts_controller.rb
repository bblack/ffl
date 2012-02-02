class ContractsController < ApplicationController
  
  def create
    @contract = Contract.create(
      :team_id => params[:team_id],
      :player_id => params[:player_id],
      :first_year => params[:first_year].presence || Date.today.year,
      :value => params[:value],
      :length => params[:length].presence || [(params[:value].to_f/15).round, 1].max # HACK
    )
    
    if @contract.valid?
      add_flash :notice, false, "Contract created"
    else
      @contract.errors.each do |att, rest|
        add_flash :error, false, "Couldn't create contract. Reason: #{att} #{rest}"
      end
    end
    
    redirect_to :back
  end
  
  def update
    Contract.update(params[:id], params.slice(:team_id, :first_year, :value, :length))
    
    @contract ||= Contract.find(params[:id])
    add_flash :notice, false, "Contract updated"
    redirect_to :back
  end
  
  def show
    @contract ||= Contract.find(params[:id])
  end
  
  def destroy
    @contract = Contract.includes(:player, :team).find(params[:id]).delete
    add_flash :warning, false, "Destroyed #{@contract.player.first_name} #{@contract.player.last_name}'s contract with #{@contract.team.name}"
    redirect_to :back
  end
  
end