module Spree
  Shipment.class_eval do
    money_methods :outstanding_balance
    has_one :dispatch_information
    accepts_nested_attributes_for :dispatch_information
    has_one :payments, dependent: :destroy, through: :order
    after_save :update_vendor_details, if: :state_changed?
  	# Update Shipment and make sure Order states follow the shipment changes
    def update_attributes_and_order(params = {})
    
      if params.key? :dispatch
          update_dispatch_info(params)
          params.delete(:dispatch) #Delete the key to update the attributes as update_attributes gives error when it has dispatch in params
      end

      if update_attributes params
        if params.key? :selected_shipping_rate_id
          # Changing the selected Shipping Rate won't update the cost (for now)
          # so we persist the Shipment#cost before calculating order shipment
          # total and updating payment state (given a change in shipment cost
          # might change the Order#payment_state)
          update_amounts

          order.updater.update_shipment_total
          order.updater.update_payment_state

          # Update shipment state only after order total is updated because it
          # (via Order#paid?) affects the shipment state (YAY)
          update_columns(
            state: determine_state(order),
            updated_at: Time.current
          )

          # And then it's time to update shipment states and finally persist
          # order changes
          order.updater.update_shipment_state
          order.updater.persist_totals
        end

        true
      end
    end

    def update_dispatch_info(params)
        if !self.dispatch_information
            self.dispatch_information = DispatchInformation.create({number: params['dispatch']})        
        else
            self.dispatch_information.number = params['dispatch']
        end
        self.dispatch_information.save!
    end

    # Decrement the stock counts for all pending inventory units in this
    # shipment and mark.
    # Any previous non-pending inventory units are skipped as their stock had
    # already been allocated.
    def finalize!
      transaction do
        pending_units = inventory_units.select(&:pending?)
        pending_manifest = ShippingManifest.new(inventory_units: pending_units)
        pending_manifest.items.each do |item_id,item| 
          item[:designs].each do |manifest|
            manifest_unstock(manifest)
          end
        end
        InventoryUnit.finalize_units!(pending_units)
      end
    end

    def update_vendor_details
      if (state == "shipped")
        update_vendors_outstanding_balance
      end
    end

    def update_vendors_outstanding_balance
      user = order.user
      if user.present? and user.has_spree_role?('vendor')
        user.store_outstanding_amount!
      end
    end

    def outstanding_balance
      outstanding = 0
      if state == 'shipped'
        self.inventory_units.each do |unit|
          outstanding += unit.variant.product.taxons[0].taxon_prices.where(currency: self.order.currency).first.amount.to_f
        end
      end
      outstanding
    end

    def outstanding_balance?
      outstanding_balance != 0
    end

    def after_cancel
      manifest.each { |item_id, item| item[:designs].each { |manifest_item| manifest_restock(manifest_item) } }
    end

    def after_resume
      manifest.each { |item_id, item| item[:designs].each { |manifest_item| manifest_unstock(manifest_item) } }
    end

    def ensure_can_destroy
      return true
    end

    def transfer_to_location(variant, quantity, stock_location)
      if quantity <= 0
        raise ArgumentError
      end

      transaction do
        new_shipment = order.shipments.create!(stock_location: stock_location, address_id: self.address_id)
        
        
        order.contents.remove(variant, quantity, { shipment: self })
        order.contents.add(variant, quantity, { shipment: new_shipment })

        all_shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(new_shipment.to_package)
        all_shipping_rates.each { |shipping_rate|
          new_shipment.add_shipping_method(shipping_rate.shipping_method, true)
        }
        
        refresh_rates
        save!
        new_shipment.save!
      end
    end
  end
end