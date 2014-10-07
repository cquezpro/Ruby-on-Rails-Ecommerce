class UserRegistrationController < ApplicationController

	layout 'productdetails'

	def new
		@userRegistration = UserRegistration.new 
	end

	def create
		@userRegistration = UserRegistration.new(userRegistration_params)
		birth_date = params[:days]
		birth_month = params[:month] 
		birth_year = params[:year]
		@userRegistration.dob = birth_date + "-" + birth_month + "-" + birth_year
		@userRegistration.state = params[:userRegistration][:state]
		@userRegistration.country = params[:userRegistration][:country]
		if @userRegistration.save
			session[:email_id] = @userRegistration.email
			session[:userid] = @userRegistration.id 
			puts "session[:user_id]",session[:userid]
			flash[:notice] = "You are registered successfully."
			redirect_to(:controller => 'user' ,:action => 'index')
		else
			render('new')
		end
	end 
	
	private
	def userRegistration_params
		params.require(:userRegistration).permit(:title,:first_name,:last_name,:email,:password,:password_confirmation,:dob,:first_name1,:last_name1,:company,:address1,:address2,:city,:state,:zipcode,:country,:additional_info,:home_phone,:mobile_phone)
	end
end
