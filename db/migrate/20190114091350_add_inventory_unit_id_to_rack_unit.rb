class AddInventoryUnitIdToRackUnit < ActiveRecord::Migration
  def change
    add_column :rack_units, :inventory_unit_id, :integer
    add_index :rack_units, :inventory_unit_id
  end
end
