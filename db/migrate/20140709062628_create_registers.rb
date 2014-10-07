class CreateRegisters < ActiveRecord::Migration

  def up
    create_table :registers do |t|
    	t.string "first_name", :limit => 25
    	t.string "last_name", :limit => 50
    	t.string "username",  :limit => 25
    	t.string "password_digest"
    	t.string "email"
        t.string "role", :default => "User"

    	t.timestamps
    end

    def down
    	drop_table :registers
    end
  end

end