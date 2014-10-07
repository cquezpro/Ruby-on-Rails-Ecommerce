class CreateUserRegistrations < ActiveRecord::Migration
  def change
    create_table :user_registrations do |t|

      t.timestamps
    end
  end
end
