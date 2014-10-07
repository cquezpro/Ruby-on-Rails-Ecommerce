class CreateProductImageAlbums < ActiveRecord::Migration
  def change
    create_table :product_image_albums do |t|

      t.timestamps
    end
  end
end
