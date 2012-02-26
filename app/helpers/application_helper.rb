module ApplicationHelper

  def brian?
    @current_user and (@current_user.name == 'brian' or @current_user.god_mode)
  end
  
end
