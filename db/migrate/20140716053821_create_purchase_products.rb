class CreatePurchaseProducts < ActiveRecord::Migration

  def up
    create_table :purchase_products do |t|

      t.timestamps
    end
  end

  def down
  	drop_table :purchase_products
  end

end
