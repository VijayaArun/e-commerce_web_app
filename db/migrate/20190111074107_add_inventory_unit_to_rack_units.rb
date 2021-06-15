class AddInventoryUnitToRackUnits < ActiveRecord::Migration
  def change
    add_reference :rack_units, :spree_inventory_unit, index: true, foreign_key: true
  end
end
