class ProductsController < ApplicationController

	before_action :confirm_logged_in, :only => [:index,:new, :edit, :delete]
	
	def index
		#@products = Product.all
		#@products = Product.all.paginate(page: params[:page], per_page: 3)
	end

	def list
		@products = Product.all
		@product_list = []
		@products.each do |p|
			@product_list << {:id => p.id,:product_name => p.product_name, :price => p.price, :qty => p.qty, :product_desc => p.product_desc, :product_image => p.product_image, :sale_for => p.sale_for}
		end
		render :json => @product_list
	end

	def categorywise_product
		@categoryid = params[:category_id].to_i
		@products = Product.where(:category_id => @categoryid).all.paginate(page: params[:page], per_page: 3)
		
	end   

	def subcategorywise_product
		@subcategoryid = params[:id].to_i
		puts "subcategory_id",@subcategoryid
		@products = Product.where(:subcategory_id => @subcategoryid).all.paginate(page: params[:page],per_page: 3)
		puts "Subcategory wise",@products.inspect
	end

	def show
		@product = Product.find(params[:id])
	end

	def new
		@product = Product.new
	end

	def create

		@product = Product.new
		@product.subcategory_id = params[:subcategory_id]
		@product.product_name = params[:product_name]
		@product.price = params[:price]
		@product.qty = params[:qty]
		@product.discount = params[:discount]
		@product.tax = params[:tax]
		@product.sale_for = true
		@product.product_desc = params[:product_desc]
		
		if !params[:product_img].nil?
			@product.product_image = params[:product_img].original_filename
			fileName = file_upload(params[:product_img],@product.id,0)
		end
		if @product.save
			flash[:notice] = "Product created successfully.-#{params[:subcategory_id]}-"
			redirect_to(:action => 'index')
		else
			#@categories = Category.order('name ASC')
			render('new')
		end
	end

	def edit
		@product = Product.find(params[:id])
	end

	def update
		
		@product = Product.find(params[:id])
		@product.subcategory_id = params[:subcategory_id]
		@product.product_name = params[:product_name]
		@product.price = params[:price]
		@product.qty = params[:qty]
		@product.discount = params[:discount]
		@product.tax = params[:tax]
		@product.sale_for = true
		@product.product_desc = params[:product_desc]
		
		if !params[:product_img].nil?
			@product.product_image = params[:product_img].original_filename
			fileName = file_upload(params[:product_img],@product.id,0)
		end

		if @product.save
			flash[:notice] = "Product updated successfully."
			redirect_to(:action => 'show', :id => @product.id)
		else
			@subcategories = Subcategory.order('name ASC')
			render('edit')
		end
	end

	def delete
		@product = Product.find(params[:id])
	end

	def destroy
		product = Product.find(params[:id]).destroy
		flash[:notice] = "Product '#{product.product_name}' destroyed successfully"
		redirect_to(:action => 'index')
	end

	def uploadImage
		
	end

	def productImage

		@product_image_album = ProductImageAlbum.new
		@product_image_album.save 
		puts "@product_image_album.id",@product_image_album.id 
		@product_image_album.product_id = params[:pid].to_i
		
		if !params[:imageupload].nil?
			
			fileName = file_upload(params[:imageupload],params[:pid],@product_image_album.id)
			# @product_image_album.image_url= params[:imageupload].original_filename
			@product_image_album.image_url = fileName
			
			if @product_image_album.save
				@msg = {:message => "File uploaded."}
			else
				@msg = {:message => "File not saved."}
			end 

		elsif params[:imageupload].blank?
				@msg = {:notice => "File not upload."}
		end
		render :json => @msg
	end

	# def upload_file
	# 	post = Product.save(params[:product_image])
	# 	render :text => "Image has been uploaded."
	# end

	def productStatus
		@product = Product.find_by_id(params[:id])
		
		@sale_for = @product.sale_for
		if @sale_for == true
			@product.sale_for = false
		else
			@product.sale_for = true
		end
		@product.save 
		puts "Sale for",@sale_for
		render :json => {:sale_for => @product.sale_for}
	end

	private

	def product_params
		params.require(:product).permit(:product_name,:price,:qty,:product_desc,:product_image)
	end

	def find_category
		if params[:category_id]
			@category = Category.find(params[:category_id])
		end
	end

end
