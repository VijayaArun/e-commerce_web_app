class RackUnit < ActiveRecord::Base
  belongs_to :spree_variant
  belongs_to :spree_order
  belongs_to :rack_item, -> { with_deleted }
  belongs_to :inventory_unit, class_name: "Spree::InventoryUnit", foreign_key: 'inventory_unit_id'
end
