class UserController < ApplicationController

	layout 'user_UI', :except => [:show,:searchProduct,:showImageAlbum,:contact]
					
	def index

		@products = Product.all
		# @visitedUser = VisitedUser.new 
				
		if !cookies[:user_visited]
			# @visitedUser.total_visitors = @visitedUser.total_visitors.to_i + 1
			track_user("Visited")
			puts "Set cookies"
			# @visitedUser.save 
		else
			puts "cookies aleredy there"
		end
	end

	def list_products	# User side index page	

		if params[:category] == "All"
			@products = Product.all
		else
			@cat_id = params[:category].to_i
			@products = Product.where(:category_id => @cat_id).all
		end
		@product_list = @products.map do |p| 
			{:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
		end
		render :json => @product_list

	end

	def categorywiseProduct # To show products

		@cat_id = params[:cid].to_i
		puts "category id", @cat_id
		@products = Product.where(:category_id => @cat_id).all
		puts "In else", @products 
		@product_list = @products.map do |p| 
			{:id => p.id,:category_id => p.category_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
		end

		render :json => @product_list
	end

	def searchProduct
				
		@product_list = []
		
		if params[:product_name].blank? == false

			value = params[:product_name]
			value1 = params[:category_id].to_i
			@subcategory = Subcategory.where("category_id = #{value1}")
			
			value2 = 0
			
				if value1 == 0
					@products = Product.where("product_name like '%#{value}%'")
					@products.each do |p|
						@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
					end	
				else
					@subcategory.each do |p|
						value2 = p.id
						@products = Product.where("product_name like '%#{value}%' and subcategory_id = #{value2}")
						@products.each do |p| 
							@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
						end
					end
				end				
			
				if	@products.blank? == true
					@product_list = {:message => "Product not found."}
				end
		    

		elsif params[:category_id].blank? == false
			
			value1 = params[:category_id].to_i
			@subcategory = Subcategory.where("category_id = #{value1}")
			puts "Subcategory",@subcategory.inspect
			value2 = 0
			
							
				if value1 == 0
					@products = Product.all
					@products.each do |p|
						@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
					end	
				else
					@subcategory.each do |p|
						value2 = p.id
						@products = Product.where("subcategory_id = #{value2}")
						puts "Products",@products.inspect
						@products.each do |p| 
							@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
						end		
					end
				end							
		end
		
		respond_to do |format|
			format.json {render json: @product_list}
			format.html {render layout: 'productdetails'}
		end
	end

	def subCategorywiseProducts
		@product_list = []
		value1 = params[:subcategory_id].to_i
		@products = Product.where("subcategory_id = #{value1}")
		@products.each do |p|
			@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
		end
		respond_to do |format|
			format.json {render json: @product_list}
			format.html {render layout: 'productdetails'}
		end
	end


	def show

		@product = Product.find(params[:id])
		pid = @product.id
		if cookies[:pid].blank?
			cookies[:pid] = {:value => pid, :expires => Time.now+7.day}
		else
			cookies[:pid] = cookies[:pid] + ",#{pid}"
		end

		render layout: 'productdetails'
	end

	def visited_products
		@visited_product_list = []
		pid = cookies[:pid]
		visited_product = Array.new
		visited_product = pid.split(',')
		visited_product.each do |p|
			visited_product_id = p.to_i
			@product_visited = Product.where("id = #{visited_product_id}")
			@visited_product_list << @product_visited
		end 
		puts "@visited_product_list",@visited_product_list.inspect
		respond_to do |format|
			format.json {render json: @visited_product_list}
			format.html {render layout: 'productdetails'}
		end	
		
	end

	def showImageAlbum 
		pid = params[:pid].to_i
		@product_image_album = ProductImageAlbum.where("product_id = #{pid}")
		@image_album = []

		@product_image_album.each do |p|
			puts "In show",p.id,p.product_id
			@image_album << {:image_url => p.image_url}
		end
		render :json => @image_album
	end
	
	def cartDetails #counts the total purchased products of a User
		@totalProducts = 0
		@totalProducts = PurchaseProduct.where(:user_id => params[:uid]).count
		puts "Total => ", @totalProducts
		render :json => @totalProducts
	end
	
	def criteriawiseSearch

		@product_list = []
		
		if params[:product_name].blank? == false

			value = params[:product_name]
			value1 = params[:category_id].to_i
			@subcategory = Subcategory.where("category_id = #{value1}")
						
			if value1 == 0
				if params[:searchCriteria].eql? "ASC"
					@products = Product.name_ascendeing_sort.where("product_name like '%#{value}%' and sale_for = '1'")
				elsif params[:searchCriteria].eql? "DESC"
					@products = Product.name_descending_sort.where("product_name like '%#{value}%' and sale_for = '1'")
				elsif params[:searchCriteria].eql? "Stock"
					@products = Product.stock_sort.where("product_name like '%#{value}%' and sale_for = '1' and qty > 0")
				elsif params[:searchCriteria].eql? "Price"
					@products = Product.price_sort.where("product_name like '%#{value}%' and sale_for = '1'")
				end

				@products.each do |p|
					@product_list << {:id => p.id, :product_name => p.product_name, :product_image => p.product_image, :product_desc => p.product_desc, :price => p.price}
				end
			else
				@subcategory.each do |p|
					value2 = p.id
					if params[:searchCriteria].eql? "ASC"
						@products = Product.name_ascendeing_sort.where("product_name like '%#{value}%' and subcategory_id = #{value2} and sale_for = '1'")
					elsif params[:searchCriteria].eql? "DESC"
						@products = Product.name_descending_sort.where("product_name like '%#{value}%' and subcategory_id = #{value2} and sale_for = '1'")
					elsif params[:searchCriteria].eql? "Stock"
						@products = Product.stock_sort.where("product_name like '%#{value}%' and subcategory_id = #{value2} and sale_for = '1' and qty > 0")
					elsif params[:searchCriteria].eql? "Price"
						@products = Product.price_sort.where("product_name like '%#{value}%' and subcategory_id = #{value2} and sale_for = '1'")
					end

					@products.each do |p| 
						@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
					end	
				end
			end	

		elsif params[:category_id].blank? == false

			value1 = params[:category_id].to_i
			@subcategory = Subcategory.where("category_id = #{value1}")
			
			if value1 == 0
				if params[:searchCriteria].eql? "ASC"
					@products = Product.name_ascendeing_sort.where("sale_for = '1'")
				elsif params[:searchCriteria].eql? "DESC"
					@products = Product.name_descending_sort.where("sale_for = '1'")
				elsif params[:searchCriteria].eql? "Stock"
					@products = Product.stock_sort.where("sale_for = '1' and qty > 0")				
				elsif params[:searchCriteria].eql? "Price"
					@products = Product.price_sort.where("sale_for = '1'")
				end 

				@products.each do |p|
					@product_list << {:id => p.id, :product_name => p.product_name, :product_image => p.product_image, :product_desc => p.product_desc, :price => p.price}
				end
			else
				@sorted_product = []
				@subcategory.each do |p|
					value2 = p.id
					@products = Product.where("subcategory_id = #{value2} and sale_for = '1' and qty > 0")
					
					@products.each do |p| 
						@sorted_product << p					
					end	
				end

				if params[:searchCriteria].eql? "ASC"
					@sorted_product = @sorted_product.sort_by{|p| p.product_name}
				elsif params[:searchCriteria].eql? "DESC"
					@sorted_product = @sorted_product.sort_by{|p| p.product_name}.reverse
				elsif params[:searchCriteria].eql? "Stock"
					@sorted_product = @sorted_product.sort_by{|p| p.qty}
				end
									
				@sorted_product.each do |p|
					@product_list << {:id => p.id,:subcategory_id => p.subcategory_id,:product_name => p.product_name,:price => p.price,:qty => p.qty,:product_desc => p.product_desc,:product_image => p.product_image}
				end
			end	
		end
		render :json => @product_list
	end
		
	def contact
		render layout: 'contact_UI'
	end

	private

	def register_params
		params.require(:register).permit(:first_name,:last_name,:username,:password,:password_confirmation,:email)
	end

end
