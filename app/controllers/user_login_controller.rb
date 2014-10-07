class UserLoginController < ApplicationController

	layout 'productdetails'

  # before_action :user_confirm_logged_in, :except => [:login, :attempt_login, :logout]
  before_action :user_confirm_logged_in, :only => [:checkout]
  

	def login
		
	end

	def attempt_login
		
		found_user = UserRegistration.where(:email => params[:inputEmail1]).first
		
  		if found_user
    				authorized_user = found_user.authenticate(params[:inputPassword1])
    	end

  		if authorized_user

  			session[:email_id] = authorized_user.email       
			  session[:userid] = authorized_user.id 
        
        checkCart
        cookies.delete :cartpid
        cookies.delete :cartdata

        userid = session[:userid].to_i 
        
        if session[:userid]
          @cart = Cart.where("user_id = #{userid}")
          @cart.each do |c|
            pid = c.product_id.to_s 
            cart_qty = c.qty
            if cookies[:cartpid].blank? && cookies[:cartdata].blank?
              cookies[:cartpid] = {:value => pid}
              cart_value = pid.to_s + "-" + cart_qty.to_s + "/"
              cookies[:cartdata] = {:value => cart_value}
            else
               cookies[:cartpid] = cookies[:cartpid] + ",#{pid}"
               cart_value = pid.to_s + "-" + cart_qty.to_s + "/"
               cookies[:cartdata] = cookies[:cartdata] + "#{cart_value}"
            end            
          end
        end

        if params[:userPage]
          redirect_to(:controller => 'user',:action => 'index')
        elsif params[:summaryPage]
          redirect_to(:action => 'checkout')
        end

		  else
			   flash[:notice] = "Invalid Email ID /password combination."
  			 redirect_to(:action => 'login')
  		end

  	end

  def checkout
        
  end

  def setOrderDelivery

        @orderDelivery = OrderDelivery.new
        @orderDelivery.buyerName = params[:buyername]
        @orderDelivery.pincode = params[:pincode]
        @orderDelivery.address = params[:address]
        @orderDelivery.country = params[:country]
        @orderDelivery.phone = params[:phone]
        @orderDelivery.payment_method = params[:paymentmethod]
        if params[:paymentmethod].eql? "Cash on Delivery"
            @orderDelivery.bank_name = nil
            @orderDelivery.ac_no = nil
        else
            @orderDelivery.bank_name = params[:bankname]
            @orderDelivery.ac_no = params[:acno]
        end
        @orderDelivery.payment_amount = params[:net_amount]
        @orderDelivery.user_id = params[:user_id]

        if @orderDelivery.save
          flash[:message] = "OrderDelivery is created."
          session[:orderDeliveryID] = @orderDelivery.id
        end

  end

  def suggestAddress
      @user_address = []
      @register = UserRegistration.find(params[:id]) 
      if params[:id].blank? == false
        @user_address << {:address1 => @register.address1,:address2 => @register.address2}
      end
      render :json => @user_address
  end

  def placeOrder 
      
  		@order = Order.new
  		@order.user_id = params[:user_id]      
      @order.user_email = params[:user_email]  		
      @order.total_price = params[:totalPrice]
      @order.total_discount = params[:totalDiscount]
      @order.total_tax = params[:totalTax]
  		@order.net_amount = params[:netTotal]
  	  @order.status = "Shipping"
      @order.delivery_id = params[:deliveryID]
      cartQty = params[:cart_qty]

  		if @order.save
          session[:orderId] = @order.id 
          updateQuantity(cartQty,@order.id,@order.user_id)
          render :json => {:message => "Order is created."}
      else
          render :json => {:notice => "Order is not created."}
      end

  end

  def logout
      
      checkCart
      session[:email_id] = nil
      session[:userid] = nil 
      if params[:pageSummary].blank? == false
        redirect_to(:controller => 'purchase_product',:action => "productSummary")
      else
        redirect_to(:controller => 'user',:action => "index")
      end
      
  end

  def updateQuantity(cartQty,orderId,userId)

        cartQtyArray = cartQty.split('/')
        cartQtyArray.each do |i|
          j = i.split('-')
          pid = j[0].to_i 
          newQty = j[1].to_i 
          @product = Product.find(pid)
          @product.qty = @product.qty - newQty
          @product.save        

          @orderitem = OrderItems.new
          @orderitem.order_id = orderId
          @orderitem.user_id = userId
          @orderitem.product_id = @product.id 
          @orderitem.qty = newQty
          @orderitem.product_price = @product.price 
          @orderitem.save 
        end

  end

  def deleteCookies
          cookies.delete :cartpid
          cookies.delete :cartdata
          userid = params[:uid]
          @cart = Cart.where("user_id = #{userid}")
          if @cart.blank? == false
            @cart.each do |c|
              c.destroy
            end
          end 
          redirect_to(:controller => 'user',:action => 'index')
  end

    
       
end
