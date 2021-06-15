module Spree
  module Api
    ShipmentsController.class_eval do
      def remove
        quantity = params[:quantity].to_i

        @shipment.order.contents.remove(variant, quantity, { shipment: @shipment })
        @shipment.reload if @shipment.persisted?
        respond_with(@shipment, default_template: :show)
      end

      def transfer_to_location
        quantity = params[:quantity].to_i
        back_orderable = StockItem.where(variant_id: params[:variant_id], stock_location_id: params[:stock_location_id]).first.backorderable
        count_on_hand = StockItem.where(variant_id: params[:variant_id], stock_location_id: params[:stock_location_id]).first.count_on_hand
        if (count_on_hand >= quantity || back_orderable == true)
          @stock_location = Spree::StockLocation.find(params[:stock_location_id])
          @original_shipment.transfer_to_location(@variant, @quantity, @stock_location)
          render json: { success: true, message: Spree.t(:shipment_transfer_success) }, status: 201
        else         
          render json: { success: false, message: Spree.t(:stock_not_available) }, status: :unprocessable_entity
        end
      end
    end
  end
end
