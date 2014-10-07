class CouponController < ApplicationController

	before_action :confirm_logged_in

	def index
		@coupon = Coupon.all 
	end

	def show
		@coupon = Coupon.find(params[:id])
	end

	def new
		@coupon = Coupon.new
	end

	def create
		@coupon = Coupon.new(coupan_params)
		if @coupon.save
			flash[:notice] = "Coupon is generated."
			redirect_to(:action => 'index')
		else
			render('new')
		end
	end

	def edit
		@coupon = Coupon.find(params[:id])
	end

	def update
		@coupon = Coupon.find(params[:id])
		if @coupon.update_attributes(coupan_params)
			flash[:notice] = "Coupon detail is updated."
			redirect_to(:action => 'show', :id => @coupon.id )
		else
			render('edit')
		end
	end

	def delete
		@coupon = Coupon.find(params[:id])
	end

	def destroy
		@coupon = Coupon.find(params[:id]).destroy
		flash[:notice] = "Coupon details are deleted."
		redirect_to(:action => 'index')
	end

	private
	def coupan_params
		params.require(:coupon).permit(:coupon_code,:coupon_discount,:product_id)
	end


end
