# Admin side Access

class AccessController < ApplicationController

	layout 'login'

  before_action :confirm_logged_in, :only => [:index]
  before_action :logged_in, :only => [:login,:registration]
  
	def login		
	end

	def index
	end

	def attempt_login
    
		if params[:email].present? && params[:password].present?
  		found_user = Register.where(:email => params[:email]).first
  			if found_user
  				authorized_user = found_user.authenticate(params[:password])
  			end
  	end

  	if authorized_user
      # mark user as logged in
      
      session[:user_id] = authorized_user.id
      session[:username] = authorized_user.username
      session[:email] = authorized_user.email
      session[:role] = authorized_user.role
	    flash[:notice] = "You are logged in"

      if session[:role] == "User"
  		  redirect_to(:controller => 'user',:action => 'index') # Filtr it afterwards.
      elsif session[:role] == "Admin"
        redirect_to(:controller => 'registers', :action => 'homepage')
  	  end

  	else
  		flash[:notice] = "Invalid Email ID /password combination."
  		redirect_to(:action => 'login')
  	end
	end

  def registration
    @register = Register.new
  end

  def create
    @register = Register.new(register_params)
    if @register.save
      session[:user_id] = @register.id
      session[:username] = @register.username
      session[:email] = @register.email
      session[:role] = @register.role
      flash[:notice] = "You are registered successfully."

      #redirect_to(:controller=> 'registers',:action => 'index')
      if session[:role] == "User"
          redirect_to(:controller => 'user',:action => 'index') # Filtr it afterwards.
      else session[:role] == "Admin"
          redirect_to(:controller => 'registers', :action => 'homepage')
      end

    else
      render('registration')
    end
  end

  def logout
    session[:user_id] = nil
    session[:username] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end

  private

  def register_params
    params.require(:register).permit(:first_name,:last_name,:username,:password,:password_confirmation,:email)
  end

end