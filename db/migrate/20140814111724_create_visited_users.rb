class CreateVisitedUsers < ActiveRecord::Migration
  def change
    create_table :visited_users do |t|

      t.timestamps
    end
  end
end
