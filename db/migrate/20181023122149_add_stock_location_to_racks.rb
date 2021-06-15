class AddStockLocationToRacks < ActiveRecord::Migration
  def change
    add_foreign_key "racks", "spree_stock_locations", column: "stock_location_id"
  end
end
