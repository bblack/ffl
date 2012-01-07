class UsersController < ApplicationController

  def create
    begin
      new_user = User.create(
        :name => params[:name],
        :email => params[:email],
        :pw_hash => Digest::MD5.hexdigest(params[:password])
      )
      
      if new_user.invalid?
        new_user.errors.each do |att, err|
          @errors << "#{att} - #{err}"
        end
      else
        @notices << "New user '#{new_user.name}' created. You can now log in with the password you supplied."
      end
    end
    
    render :new
  end

end
