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
      add_notice "Contract created"
    else
      @contract.errors.each do |att, rest|
        add_error "Couldn't create contract. Reason: #{att} #{rest}"
      end
    end
    params[:id] = @contract.id
    render :show
  end
  
  def update
    Contract.update(params[:id], params.slice(:team_id, :first_year, :value, :length))
    
    @contract ||= Contract.find(params[:id])
    add_notice "Contract updated"
    render :show
  end
  
  def show
    @contract ||= Contract.find(params[:id])
  end
  
end