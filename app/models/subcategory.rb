class Subcategory < ActiveRecord::Base

	scope :sorted, lambda { order ("name ASC")}
	
end
