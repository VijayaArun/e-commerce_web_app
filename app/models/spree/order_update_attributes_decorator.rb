module Spree
  OrderUpdateAttributes.class_eval do 
    def apply
      assign_order_attributes
      @order.bill_address = @order.ship_address
      assign_payments_attributes

      if order.save
        order.set_shipments_cost if order.shipments.any?
        true
      else
        false
      end
    end
  end

end