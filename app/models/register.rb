class Register < ActiveRecord::Base

	has_secure_password

	EMAIL_REGEX = /\A[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\z/i

	validates :first_name, :presence => true, :length => {:within => 0..25} 
	validates :last_name, :presence => true, :length => {:within => 0..50}
	validates :username, :presence => true, :length => {:within => 8..25}, :uniqueness => true
	validates :email, :presence => true, :length => {:maximum => 100}, :format => EMAIL_REGEX, :confirmation => true

	scope :sorted, lambda { order ("last_name ASC, first_name ASC")}

end