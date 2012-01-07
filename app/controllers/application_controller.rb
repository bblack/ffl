class ApplicationController < ActionController::Base
  #protect_from_forgery
  before_filter :set_errors
  
  def set_errors
    @errors = []
    @warnings = []
    @notices = []
  end
  
  def login
    users = User.where(:name => params[:name], :pw_hash => Digest::MD5.hexdigest(params[:password]))
    if users.count == 0
      @errors << "User '#{params[:name]}' doesn't exist, or password is incorrect."
    elsif users.count > 1
      @errors << "Lolwut, found multiple users with that name and password"
    else
      session[:user_id] = users.first.id
      @notices << "Logged in. Welcome, #{users.first.name}!"
    end
    
    render 'leagues/choose'
  end
  
  def logout
    reset_session
    @notices << "You are now logged out"
  end
  
end
