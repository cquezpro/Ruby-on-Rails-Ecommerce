class CreateProducts < ActiveRecord::Migration

  def up
    create_table :products do |t|
      t.integer "category_id"
      t.string "product_name", :limit => 25
      t.float "price" 
      t.integer "qty"
      t.boolean "sale_for"
      t.string "product_desc", :limit => 150
      t.string "product_image"
      t.timestamps
    end
  end

  def down
  	drop_table :products
  end

end