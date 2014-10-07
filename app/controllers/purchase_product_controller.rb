class PurchaseProductController < ApplicationController

	layout 'productdetails',only: [:index,:productSummary]

	def index
	end

	def createPurchaseDetails

		@product = Product.find(params[:id])
		pid = @product.id
		product_qty = @product.qty 
		discountRate = @product.discount 
		taxRate = @product.tax 
		purchase_qty = 1
		
		if cookies[:cartpid].blank?
			
			if cookies[:cartdata].blank?

				if params[:qty].blank?
						purchase_qty = purchase_qty 
				else
						purchase_qty = params[:qty].to_i
				end

				availableQty = @product.qty

				if availableQty < purchase_qty
					flash[:notice] = "Quantity out off stock."
					# redirect_to(:controller => 'user',:action => 'index')
				else
					cookies[:cartpid] = {:value => pid, :expires => Time.now + 7.days}
					cart_product_data = pid.to_s + "-" + purchase_qty.to_s + "/"
					cookies[:cartdata] = {:value => cart_product_data, :expires => Time.now + 7.days}
				end
				
			end
							
		else
				verifypid = checkProductID(pid)
		
				if verifypid[:text].eql? "Product Exists"
					cart_qty = cookies[:cartdata]
					oldQty = getQuantity(pid,cart_qty)

					if params[:qty].blank? == false
						purchase_qty = params[:qty].to_i
					elsif params[:opt].blank? == false
						opr = params[:opt]
						if opr == "sub"
							if oldQty[:text].to_i == 1
								purchase_qty = 1
							else
								oldQty = oldQty[:text].to_i - 1
								purchase_qty = oldQty
							end
						else
							oldQty = oldQty[:text].to_i + 1
							purchase_qty = oldQty
						end 
					else
						purchase_qty = oldQty[:text].to_i
					end

					availableQty = @product.qty
										
					if availableQty < purchase_qty
						flash[:notice] = "Quantity out off stock."
						# redirect_to(:controller => 'user',:action => 'index')
					else
						setQuantity(pid,purchase_qty,cart_qty)
					end
					
				else

					puts "Product not Exists"
					
					if params[:qty].blank?
						purchase_qty = purchase_qty 
					else
						purchase_qty = params[:qty].to_i
					end

					availableQty = @product.qty
					if availableQty < purchase_qty				
						flash[:notice] = "Quantity out off stock."
						# redirect_to(:controller => 'user',:action => 'index')
					else
						cookies[:cartpid] = cookies[:cartpid] + ",#{pid}"
						cart_product_data = pid.to_s + "-" + purchase_qty.to_s + "/" 
						cookies[:cartdata] = cookies[:cartdata] + "#{cart_product_data}"
					end
										
				end
		end	
		checkCart
			
		if params[:opt].blank? == false
			redirect_to(:controller => 'purchase_product',:action => 'productSummary')
		else
			redirect_to(:controller => 'user',:action => 'index')
		end
	end

	def list_cart_details
				
		@total = 0
		@totalAmount = 0
		@totalDiscount = 0
		@totalTax = 0
		@purchase_list = []	
		@totalProducts = 0	
		totalcartPid = params[:cart_product]	

		cart = Array.new
		cart = totalcartPid.split(',')
		@totalProducts = cart.size
		cart.each do |purchase|
			cart_pid = purchase.to_i 
			@product = Product.where("id = #{cart_pid}")
			
			@product.each do |p|
				pid = p.id
				pqty = getQuantity(pid,params[:cart_qty])
				puts "pqty",pqty
				pprice = p.price 
				pdisc_rate = p.discount 
				ptax_rate = p.tax 
				psubtotal = (pprice.to_f) * (pqty[:text].to_i)
				pdisc = ((psubtotal.to_f * pdisc_rate)/100)
				ptax = ((psubtotal.to_f * ptax_rate)/100)
				product_total = psubtotal - pdisc + ptax
				puts "product_total",product_total
				@totalAmount = @totalAmount + product_total
				@totalDiscount = @totalDiscount + pdisc
				@totalTax = @totalTax + ptax
				@purchase_list << {:product_id => pid,:totalProducts => @totalProducts,:product_image => p.product_image,:product_name => p.product_name,:product_desc => p.product_desc,:qty => pqty[:text],:price => pprice,:product_dicount => pdisc,:product_tax => ptax,:product_amount => product_total,:totalAmount => @totalAmount, :totalDiscount => @totalDiscount,:totalTax => @totalTax}
			end
		end

		render :json => @purchase_list

	end

	def deleteQuantity

		pid = params[:id]
		cart_pid = cookies[:cartpid]
		cart_data = cookies[:cartdata]
		
		temp = Array.new 
		temp1 = Array.new 
		temp2 = Array.new 
		temp3 = Array.new 

		dataArray = cart_data.split('/')
		dataArray.each do |i|
			j = i.split('-')
			if j[0].to_i != pid.to_i  
				temp = temp << j.join('-')
			end
		end
		temp1 = temp.join('/')
		puts "temp1",temp1.inspect
		cookies[:cartdata] = {:value => temp1}
		puts "cookies[:cartdata]",cookies[:cartdata].inspect

		pidArray = cart_pid.split(',')
		pidArray.each do |i|
			puts i,i.class 
			if i.to_i != pid.to_i
				temp2 = temp2 << i.to_s
			end
		end
		temp3 = temp2.join(',')
		puts "temp2",temp2.inspect
		cookies[:cartpid] = {:value => temp3}
		updateCart		
		redirect_to(:action => 'productSummary')
		
		# @product_remove = {:message => "Product is removed from cart.",:temp1 => temp1,:temp2 => temp2}
		# render :json => @product_remove
		
	end

	def productSummary
	end

	def voucherDiscount

		voucher_code = params[:voucher_code]
		# user_id = params[:uid]
		cart_product = params[:cart_product]
		
		grandTotal = params[:amount].to_f
		@coupon = Coupon.where("coupon_code = '#{voucher_code}'")
		discountRate = 0
		coupon_pid = 0
		flag = false;

		@coupon.each do |c|
			discountRate = c.coupon_discount
			coupon_pid = c.product_id
		end
		
		pidArray = cart_product.split(',')
		pidArray.each do |p|
			pid = p.to_i 
			if coupon_pid == pid
				flag = true
			end
		end

		if flag == true
			voucher_discount_amount = ((grandTotal * discountRate)/100)
			@net_grand_total = grandTotal - voucher_discount_amount
			render :json => @net_grand_total
		else
			@coupon_message = {:message => "Invalid Coupon."}
			render :json => @coupon_message
		end

	end

	private 
	
	def checkProductID(pid)

			cart_pid = cookies[:cartpid].to_s
			cart_array = cart_pid.split(',')
			product_id = pid.to_s
						
			if cart_array.include?(product_id)
				return :text => "Product Exists"
			else
				return :text => "Product not Exists"
			end 
	end

	def setQuantity(pid,purchase_qty,countCart)

		temp = Array.new 
		temp1 = Array.new 
		cart_data = countCart
		dataArray = cart_data.split('/')
		dataArray.each do |i|
			j = i.split('-')
			if j[0].to_i == pid 
				j[1] = purchase_qty
			end
			temp = temp << j.join('-')
		end
		temp1 = temp.join('/')
		cookies[:cartdata] = {:value => temp1 + "/"}
	end


	def getQuantity(pid,cart_qty)

		purchased_qty = 0
		cart_data = cart_qty
		dataArray = cart_data.split('/')
		dataArray.each do |i|
			j = i.split('-')
			if j[0].to_i == pid 
				purchased_qty = j[1] 
			end
		end
		return :text => purchased_qty
	end

end