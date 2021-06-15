module Spree
  module Admin
    module Orders
      CustomerDetailsController.class_eval do

        def update
          prevIdentifier = @order.user.nil? ? Spree::User.with_deleted.find(@order.user_id).created_by.identifier : @order.user.created_by.identifier
          if @order.bill_address.nil?
            params[:order][:bill_address_attributes] = params[:order][:ship_address_attributes]
          end
          params[:order]["user_id"] = params["user_id"]
          if @order.contents.update_cart(order_params)
            newIdentifier = @order.user.created_by.identifier

            if prevIdentifier != newIdentifier
              @order.contents.update_cart({"number" => @order.number.gsub(prevIdentifier, newIdentifier) })
            end

            if should_associate_user?
              requested_user = Spree.user_class.find(params[:user_id])
              @order.associate_user!(requested_user, @order.email.blank?)
            end

            unless @order.completed?
              @order.next
              @order.refresh_shipment_rates
            end

            flash[:success] = Spree.t('customer_details_updated')
            redirect_to edit_admin_order_url(@order)
          else
            render action: :edit
          end
        end

        def order_params
          params.require(:order).permit(
              :email,
              :use_billing,
              :user_id,
              bill_address_attributes: permitted_address_attributes,
              ship_address_attributes: permitted_address_attributes
          )
        end

      end
    end
  end
end