class CreateRacks < ActiveRecord::Migration
  def change
    create_table :racks do |t|
      t.integer  "stock_location_id", limit: 4, null: false
      t.string "name"
			t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end