class ContractsController < ApplicationController
  
  def create
    @contract = Contract.create(
      :team_id => params[:team_id],
      :player_id => params[:player_id],
      :first_year => params[:first_year].presence || Date.today.year,
      :value => params[:value],
      :length => params[:length].presence || (params[:value].to_f/15).round # HACK
    )
    if @contract.valid?
      add_flash :notice, false, "Contract created"
      redirect_to :action => 'show', :id => @contract.id
      #render :action => 'show', :id => @contract.id
    else
      @contract.errors.each do |att, rest|
        add_flash :error, true, "Couldn't create contract. Reason: #{att} #{rest}"
        render :inline => '', :layout => true
      end
    end
  end
  
  def update
    Contract.update(params[:id], params.slice(:team_id, :first_year, :value, :length))
    
    @contract ||= Contract.find(params[:id])
    add_flash :notice, true, "Contract updated"
    render :show
  end
  
  def show
    @contract ||= Contract.find(params[:id])
  end
  
end