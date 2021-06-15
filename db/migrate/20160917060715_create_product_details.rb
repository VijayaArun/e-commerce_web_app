class CreateProductDetails < ActiveRecord::Migration
  def change
    create_table :product_details do |t|
      t.string :set_size,                 default: '1'
      t.integer :product_id,        limit: 4
      t.timestamps null: false
    end

    add_foreign_key "product_details", "spree_products", column: "product_id"

  end
end
