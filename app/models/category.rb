class Category < ActiveRecord::Base

	#has_many :products

	validates :name, :presence => true
	validates :description, :presence => true

	scope :sorted, lambda { order ("name ASC")}
	
end
