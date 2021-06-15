module Spree
  module Admin
    OrdersController.class_eval do 
      include OrderHelper
      def index
        query_present = params[:q]
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        @hide_canceled_orders = params[:q][:state_not_eq] == '1' || params[:q][:state_not_eq].nil?
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
        params[:q][:completed_at_not_null] = '' unless @show_only_completed
        params[:q][:state_not_eq] = 'canceled' if @hide_canceled_orders

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

        if params[:q][:created_at_gt].present?
          params[:q][:created_at_gt] = begin
                                         Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                       rescue
                                         ""
                                       end
        end

        if params[:q][:created_at_lt].present?
          params[:q][:created_at_lt] = begin
                                         Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                       rescue
                                         ""
                                       end
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Order.accessible_by(current_ability, :index).ransack(params[:q])

        # lazy loading other models here (via includes) may result in an invalid query
        # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
        # see https://github.com/spree/spree/pull/3919
        @orders = if query_present
          @search.result(distinct: true)
        else
          @search.result
        end

        # Not using this because of read and unread order functionality.
        # @orders = @orders.
        #   page(params[:page]).
        #   per(params[:per_page] || Spree::Config[:orders_per_page])

        @read_orders = Kaminari.paginate_array(@orders.select{|order| order.order_detail && order.order_detail.read
         }).page(params[:read_page]).per(params[:per_page] || Spree::Config[:orders_per_page])
        @unread_orders = Kaminari.paginate_array(@orders.select{|order| !order.order_detail || !order.order_detail.read 
         }).page(params[:unread_page]).per(params[:per_page] || Spree::Config[:orders_per_page])
        
        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def edit        
        if !@order.order_detail.present?
          order_detail = OrderDetail.new(order_id: @order.id, read: true)
          order_detail.save
        elsif !@order.order_detail.read
          @order.order_detail.read = true
          @order.order_detail.save
        end
        require_ship_address

        unless @order.completed?
          @order.refresh_shipment_rates
        end
      end

      def show
        load_order
        respond_with(@order) do |format|
          format.pdf do
            template = params[:template] || "invoice"
            if ENV['USE_INVOICE_NUMBER_FOR_ORDER_NUMBER'] != 'true'
              if (template == "invoice") && Spree::PrintInvoice::Config.use_sequential_number? && !@order.invoice_number.present?
                @order.invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
                @order.invoice_date = Date.today
                @order.save!
              end
            end
            if (template == "dispatcher")
              @rack_data = rack_item(@order)
            else
              @data = items(@order)
            end
            render :layout => false , :template => "spree/admin/orders/#{template}.pdf.prawn"
          end
        end
      end

      def cancel
        @order.canceled_by(try_spree_current_user)
        flash[:success] = Spree.t(:order_canceled)
        redirect_to "#{request.protocol}#{request.host_with_port}#{admin_orders_path}"
      end

      def cancel_multiple_orders
        order_numbers = params[:order_nos]
        message = {}
        unless (order_numbers.nil?)
          total_orders = order_numbers.length
          deleted_orders = 0
          order_numbers.each {|order_number|
            order = Order.includes(:adjustments).find_by_number!(order_number)
            begin
              order.canceled_by(try_spree_current_user)
              deleted_orders += 1
            rescue
              message[:error] = Spree.t(:some_orders_not_deleted)
            end
          }
          if total_orders == deleted_orders
            message[:success] = Spree.t(:deleted_selected_orders)
          elsif deleted_orders > 0
            message[:success] = Spree.t(:few_deleted_orders)
          elsif deleted_orders == 0
            message[:error] = Spree.t(:no_deleted_orders)
          end
        else
          message[:error] = Spree.t(:no_deleted_orders)
        end
        render :json => message
      end

      # Gathered data but not used anywhere.
      def items_ordered(shipments)
        @item_details = []
        shipments.each do |shipment|
          line_items = shipment.line_items
          product_ids = []
          products = []
          items = []
          line_items.each do |line_item|
            product = line_item.product
            products << product
            product_ids << product.id
            items << product.taxons.first
          end

          items.uniq!
          @item_details << items.map do |item|
            total_quantity = 0
            total_sets = 0
            total_price = 0
            price = item.taxon_prices.where(currency: @order.currency).first.amount.to_f
            perfect_set = true
            products.each do |product|
              if (product.taxons.first.id == item.id)
                quantity = shipment.inventory_units.where(variant_id: product.master.id).count
                total_quantity += quantity
                total_sets += (quantity / product.product_detail.set_size.to_i)
                perfect_set = perfect_set && (quantity % product.product_detail.set_size.to_i == 0)
              end
            end
            total_price = price * total_quantity
            if (perfect_set)
              total_quantity = -1
            else
              total_sets = -1
            end            
            {
              name: item.name,
              price: price,
              quantity: total_quantity,
              set: total_sets,
              total_price: total_price
            }
          end
        end
      end

      def  rack_item(order)
        # Grouping by the ID means that we don't have to call out to the association accessor
        # This makes the grouping by faster because it results in less SQL cache hits.
       item_details = {}
        manifest_items = order.inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
          manifest_item = variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
            variant = units.first.variant
            taxon = variant.product.taxons.with_deleted.first
              if (item_details[taxon.id].nil?)
                  item_details[taxon.id] = {
                    name: taxon.name,
                    quantity: units.length
                  }
              else
                item_detail = item_details[taxon.id]
                item_detail[:quantity] += units.length
              end
            states = {}
            units.group_by(&:state).each { |state, iu| states[state] = iu.count }

            line_item = units.first.line_item
            ManifestItem.new(line_item, variant, units.length, states, taxon.id)
          end
        end.flatten

        manifest_items.each do |manifest_item|
          item_detail = item_details[manifest_item.item_id]
          product = manifest_item.variant.product          
          set_size = product.product_detail.set_size.to_i
          if (item_detail[:rack_units].nil?)
            item_detail[:rack_units] = manifest_item.rack_units
          end
          if (item_detail[:designs].nil?)
            item_detail[:designs] = [manifest_item]
            item_detail[:perfect_set] = true
            item_detail[:set] = 0
          else
            item_detail[:designs] << manifest_item
          end
          item_detail[:set] += (manifest_item.rack_units.first[:count_on_hand] / set_size.to_i) if item_detail[:perfect_set]
          item_detail[:perfect_set] = item_detail[:perfect_set] && (manifest_item.rack_units.first[:count_on_hand] % set_size == 0)
          if !item_detail[:perfect_set]
            item_detail[:set] = -1
          end
        end   
        item_details
      end
      
      def items(order)
        # Grouping by the ID means that we don't have to call out to the association accessor
        # This makes the grouping by faster because it results in less SQL cache hits.
       item_details = {}
        manifest_items = order.inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
          manifest_item = variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
            variant = units.first.variant
            taxon = variant.product.taxons.with_deleted.first
            price = taxon.taxon_prices.where(currency: units.first.order.currency).first.amount.to_f
            if (item_details[taxon.id].nil?)          
              item_details[taxon.id] = {
                name: taxon.name,
                price: price,
                quantity: units.length,
                total_price: units.length * price
              }
            else
              item_detail = item_details[taxon.id]
              item_detail[:quantity] += units.length
              item_detail[:total_price] += units.length * price
            end
            states = {}
            units.group_by(&:state).each { |state, iu| states[state] = iu.count }

            line_item = units.first.line_item
            ManifestItem.new(line_item, variant, units.length, states, taxon.id)
          end
        end.flatten
        manifest_items.each do |manifest_item|
          item_detail = item_details[manifest_item.item_id]
          product = manifest_item.variant.product
          set_size = product.product_detail.set_size.to_i
          if (item_detail[:designs].nil?)
            item_detail[:designs] = [manifest_item]
            item_detail[:perfect_set] = true
            item_detail[:set] = 0
          else
            item_detail[:designs] << manifest_item
          end
          item_detail[:set] += (manifest_item.quantity / set_size.to_i) if item_detail[:perfect_set]
          item_detail[:perfect_set] = item_detail[:perfect_set] && (manifest_item.quantity % set_size == 0)
          if !item_detail[:perfect_set]
            item_detail[:set] = -1
          end
        end
        item_details
      end
    end
  end
end