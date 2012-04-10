class ContractsController < ApplicationController
  
  def index
    render :text => "No league selected" if @current_league.nil?
    contracts = @current_league.active_contracts.includes(:player, :team)
    retval = "Player,Position,Team,Owner,Contract value,Contract start,Contract length,Contract end"
    retval += "\r\n"
    contracts.each do |c|
      retval += [
        "#{c.player.first_name} #{c.player.last_name}",
        c.player.position,
        c.player.nfl_team,
        c.team.name.gsub(',',' '),
        c.value,
        c.first_year,
        c.length,
        c.first_year.nil? || c.length.nil? ? nil : c.first_year + c.length - 1
      ] * ','
      retval += "\r\n"
    end
    send_data retval, :type => 'application/csv', :filename => "#{@current_league.name}_#{Time.now.iso8601}.csv"
  end
  
  def create
    @contract = Contract.create(
      :team_id => params[:team_id],
      :player_id => params[:player_id],
      :first_year => params[:first_year].presence || Date.today.year,
      :value => params[:value],
      :length => params[:length].presence || @current_league.contract_length_for_value(params[:value])
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
    change_current_league(@contract.team.league_id)
  end
  
  def destroy
    @contract = Contract.includes(:player, :team).find(params[:id])
    @contract.nix(params[:msg])
    @contract.save!
    add_flash :warning, false, "Nixed #{@contract.player.full_name}'s contract with #{@contract.team.name}"
    redirect_to :back
  end
  
end