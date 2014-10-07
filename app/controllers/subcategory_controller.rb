class SubcategoryController < ApplicationController

	def index
		@subcategories = Subcategory.all 
	end

	def show
		@subcategory = Subcategory.find(params[:id])
	end
			
	def list
		@subcategories = Subcategory.all
		puts "Subcategory",@subcategories.inspect
		@subcategory_list = []
		@subcategories.each do |c|
			@subcategory_list << {:id => c.id,:subcategory_name => c.name, :subcategory_desc => c.description}

		end
		render :json => @subcategory_list
	end

	def new
		@subcategory = Subcategory.new
	end

	def create
		@subcategory = Subcategory.new(subcategory_params)
		# puts "Subcategory New =>",@subcategory.inspect
		if @subcategory.save
			flash[:notice] = "Subcategory created successfully."
			redirect_to(:action => 'index')
		else
			render('new')
		end
	end

	def edit
		@subcategory = Subcategory.find(params[:id])
	end

	def update
		@subcategory = Subcategory.find(params[:id])
		if @subcategory.update_attributes(subcategory_params)
			flash[:notice] = "Your Subcategory details are updated."
			redirect_to(:action => 'show', :id => @subcategory.id )
		else
			render('edit')
		end
	end

	def listSubcategory # Categorywise listing of subcategories
		@categoryid = params[:category_id].to_i
		@subcategory = Subcategory.where(:category_id => @categoryid).all.paginate(page: params[:page], per_page: 3)
	end

	def delete
		@subcategory = Subcategory.find(params[:id])
	end

	def destroy
		subcategory = Subcategory.find(params[:id]).destroy
		flash[:notice] = "Subcategory details are deleted."
		redirect_to(:action => 'index')
	end

	private

	def subcategory_params
		params.require(:subcategory).permit(:category_id,:name,:description)
	end
	
end
