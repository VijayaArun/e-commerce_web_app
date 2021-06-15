module Spree
  InventoryUnit.class_eval do
  	has_one :rack_unit, dependent: :destroy, class_name: "RackUnit"
  	after_save :check_state
  	after_destroy :mark_as_destroyed
		def mark_as_destroyed
			rack_unit_to_delete = RackUnit.where(inventory_unit_id: self.id)
			if (rack_unit_to_delete != nil)
				rack_unit_to_delete.each do |rck_unit|
					rack_unit_to_delete.destroy(rck_unit.id)
				end
			end
		end
    def ensure_can_destroy
      if !backordered? && !on_hand?
        errors.add(:state, :cannot_destroy, state: state)
        return false
      end
    end

    # 1. proper condition
    # 2. loop 1 to get all rack stock (rack items list)
    # 3. loop 2 for availability (rack units, subtract)
    # 4. reserving loop (reserve from proper rack)
    def check_state
    	rack_stocks = []
    	if state_changed?
    		if (self.state_was.nil? and self.state == "on_hand")
    			# create a rack unit with either on_hand or backordered
    			stock_location_id = Shipment.where(id: self.shipment_id).first.stock_location_id
	 				racks = Spree::Rack.where(stock_location_id: stock_location_id).map { |e| e.id }
	 				rack_items = RackItem.where(variant_id: self.variant_id, rack_id: racks)
	 				stock_available = false
	    		rack_items.each do |rack_item| 
	    			rack_item_id = rack_item.id
	    			rack_name = Spree::Rack.where(id: rack_item.rack_id).first.name
	    			rack_count_on_hand = rack_item.count_on_hand
	    			rack_id = rack_item.rack_id
	    			pending_rack_units = RackUnit.where(state: "on_hand", spree_variant_id: self.variant_id, rack_item_id: rack_item_id).count
	    			rack_stock = {
	    				rack_item_id: rack_item_id,
	    				rack_id: rack_id,
	    				rack_name: rack_name,
	    				rack_count_on_hand: rack_count_on_hand - pending_rack_units
	    			}
    				rack_stocks << rack_stock
	    			if (rack_stock[:rack_count_on_hand] > 0)
	    				stock_available = true
	    			end
	    		end
	    		unless stock_available
	    			rack_unit = RackUnit.new(spree_variant_id: self.variant_id, spree_order_id: self.order_id, state: "backordered", inventory_unit_id: self.id)
	    		else
	    			rack_unit = RackUnit.new(spree_variant_id: self.variant_id, spree_order_id: self.order_id, rack_item_id: rack_stocks.first[:rack_item_id], state: "on_hand", inventory_unit_id: self.id)	    			
	    		end
    			rack_unit.save
    		elsif (self.state_was == "backordered" and self.state == "on_hand")
    			# update state of rack unit
    		elsif (self.state_was == "on_hand" and self.state == "shipped")
    			rack_unit = RackUnit.where(inventory_unit_id: self.id).first
					rack_unit.update(state: "shipped")
				end
				return true
    	end
    end
  end
end
