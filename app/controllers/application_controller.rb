class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_errors
  
  def set_errors
    @warnings = [] # ["You're kind of ugly", "It's cold outside"]
    @errors = [] # ["Holy shit the world is asplode"]
  end
end
