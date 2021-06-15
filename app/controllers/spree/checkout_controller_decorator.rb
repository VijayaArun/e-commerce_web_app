module Spree
  CheckoutController.class_eval do

    def before_address
      # if the user has a default address, a callback takes care of setting
      # that; but if he doesn't, we need to build an empty one here
      default = { country_id: Country.default.id }
      if @order.ship_address.present?
        if @order.bill_address.nil?
          @order.bill_address = @order.ship_address
        end
      end
      @order.build_bill_address(default) unless @order.bill_address
      @order.build_ship_address(default) if @order.checkout_steps.include?('delivery') && !@order.ship_address
    end

  end

end