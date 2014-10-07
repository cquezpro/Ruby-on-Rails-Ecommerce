class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  require 'fileutils'

  private

  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'access', :action => 'login')
      # return false    #halts the before_action
    end
  end

  def user_confirm_logged_in
    unless session[:userid]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'user_login', :action => 'login')
      return false
    else
      return true 
    end

  end

  
  def logged_in
  	if session[:user_id] 
        if session[:role] == "Admin"
  		    flash[:notice] = "Please logout before Registration."
  		    redirect_to(:controller => 'registers', :action => 'index')
        else
          flash[:notice] = "Please logout before Registration."
          redirect_to(:controller => 'user', :action => 'index')
        end
    end
  end

  def file_upload(upload,pid,id)

    name = upload.original_filename
    product_id = pid.to_i 
    prod_img_album_id = id.to_i
   
    # directory = "public/images"
    # path = File.join(directory,name)
    filepath = "public/images/" + "#{product_id}"
    Dir.mkdir(filepath) unless File.exists?(filepath)
    checkFile = filepath + "/#{name}"

    if File.exist?(checkFile) 
      name = prod_img_album_id.to_s + "_" + product_id.to_s + "_" + name
    end
    path = Rails.root.join(filepath,name)
    File.open(path,"wb") {|f| f.write(upload.read)}          
    return name 
  end
    
  def track_user(user_visited)
    cookies[:user_visited] = {:value => user_visited, :expires => Time.now+7.day}
  end

  def checkCart


        if session[:userid]

            if cookies[:cartpid].blank? == false && cookies[:cartdata].blank? == false
                
                cartQty = cookies[:cartdata]
                cartQtyArray = cartQty.split('/')
                cartQtyArray.each do |i|
                  j = i.split('-')
                  pid = j[0].to_i 
                  cart_pid = 0

                  @carts = Cart.all

                  if @carts.blank?
                      @cart = Cart.new
                      @cart.user_id = session[:userid].to_i 
                      @cart.product_id = j[0].to_i 
                      @cart.qty = j[1].to_i 
                      @cart.save 
                  else
                        puts "all cart =>",@carts.inspect
                        @cart = Cart.find_by_product_id(pid) 
                        
                          if @cart.blank?
                            puts "pid not exist in cart "
                            @cart = Cart.new
                            @cart.user_id = session[:userid].to_i 
                            @cart.product_id = j[0].to_i 
                            @cart.qty = j[1].to_i 
                            @cart.save 
                          else
                            # @cart = Cart.find_by_product_id(pid)
                            @cart.qty = j[1].to_i 
                            @cart.save
                          end
                                             
                  end 
                end
                
            end
        end 
  end

  def updateCart

    if session[:userid]
      uid = session[:userid]
      if cookies[:cartpid].blank? == false && cookies[:cartdata].blank? == false
        @cart = Cart.where("user_id = #{uid}")
        if @cart.blank? == false
            @cart.each do |c|
              c.destroy
            end
        end 

        cartQty = cookies[:cartdata]
        cartQtyArray = cartQty.split('/')
        cartQtyArray.each do |i|
            j = i.split('-')
            pid = j[0].to_i 
            cart_pid = 0
            @cart1 = Cart.new 
            @cart1.user_id = session[:userid].to_i 
            @cart1.product_id = j[0].to_i 
            @cart1.qty = j[1].to_i 
            @cart1.save 
        end

      end
    end 

  end

end
