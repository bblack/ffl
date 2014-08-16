Ffl::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  root :to => 'application#index'
  match 'application/logout' => 'application#logout'
  match 'application/login' => 'application#login'
  resources :players
  resources :leagues do
    resources :teams, :only => :index
    get 'draft_form' => 'leagues#draft_form', :on => :member
    post 'draft'     => 'leagues#draft', :on => :member
  end
  resources :teams, :except => :index
  match 'teams/:id/fetch_espn' => 'teams#fetch_espn' # should be post
  match 'teams/:id/players/:player_id/drop' => 'teams#drop_player' # should be post
  resources :users#, :only => [:create]
  resources :rfa_periods
  match 'rfa_periods/:id/bigredbutton' => 'rfa_periods#bigredbutton', :via => [:post]
  resources :rfa_bids
  resources :rfa_decisions
  resources :player_value_changes
end
