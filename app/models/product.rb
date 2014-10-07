class Product < ActiveRecord::Base

	#belongs_to :category

	#scope :with_category_id, lambda { |category_id| {:include => :categories, :conditions => ["category_id = ?", category_id]} }
	#scope :with_category_id, lambda { |category_id| where(category_id: [*category_id])}
	#scope :with_category_id, lambda { |category_id| where('category.id = ?',id).joins(:category)}
	
	scope :name_ascendeing_sort, lambda {order("product_name ASC")}
	scope :name_descending_sort, lambda {order("product_name DESC")}
	scope :stock_sort, lambda {order ("qty ASC")}
	scope :price_sort, lambda {order("price ASC")}
	
	# scope :with_country_name, lambda { |country_name| where('countries.name = ?', country_name).joins(:country)}

	# scope :with_category_id, lambda {
 #  		where(
 #    		'EXISTS (SELECT * from products, categories WHERE categories.id = products.category_id)'
 #  		)
	# }

	# def self.search(search)
	# 	puts "Search => " + search
 #  		search_condition = "%" + search + "%"
 #  		find(:all, :conditions => ['product_name LIKE ?', search_condition])

	# end

	# scope :matches, lambda {
	# 	where(
	# 		'EXISTS(select * from products where product_name like '%%')'
	# 	)
	# }
end
