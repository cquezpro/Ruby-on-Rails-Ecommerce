# Admin side

class RegistersController < ApplicationController

	# before_action :confirm_logged_in
	
	def index
		@registers = Register.sorted.paginate(page: params[:page], per_page: 3)
	end

	def homepage
	end

	def show
		@register = Register.find(params[:id])
	end

	def new
		@register = Register.new
	end

	def create
		@register = Register.new(register_params)
		if @register.save
			flash[:notice] = "You are registered successfully."
			redirect_to(:action => 'index')
		else
			render('new')
		end
	end

	def edit
		@register = Register.find(params[:id])
	end

	def update
		@register = Register.find(params[:id])
		if @register.update_attributes(register_params)
			flash[:notice] = "Your registration details are updated."
			redirect_to(:action => 'show', :id => @register.id )
		else
			render('edit')
		end
	end

	def delete
		@register = Register.find(params[:id])
	end

	def destroy
		register = Register.find(params[:id]).destroy
		flash[:notice] = "Registration details are deleted."
		redirect_to(:action => 'index')
	end

	def logout
	    session[:user_id] = nil
	    session[:username] = nil
	    flash[:notice] = "Logged out"
	    redirect_to(:controller => 'access' , :action => "login")
  	end

	private

	def register_params
		params.require(:register).permit(:first_name,:last_name,:username,:password,:password_confirmation,:email)
	end

end