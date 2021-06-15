module Spree
  module Admin
    ReportsController.class_eval do
      include VendorHelper
      helper_method :order_condition_list, :list_products, :list_stock_locations, :list_racks
      class << self
        def available_reports
          @@available_reports
        end

        def add_available_report!(report_key, report_description_key = nil)
          if report_description_key.nil?
            report_description_key = "#{report_key}_description"
          end
          @@available_reports[report_key] = { name: Spree.t(report_key), description: Spree.t(report_description_key) }
        end
      end

      def initialize
        super
        ReportsController.add_available_report!(:sales_total)
        ReportsController.add_available_report!(:visit)
        # ReportsController.add_available_report!(:product_stock_history)
        ReportsController.add_available_report!(:product_price_history)
        ReportsController.add_available_report!(:order)
        ReportsController.add_available_report!(:rack_stock)
      end

      def index
        @reports = ReportsController.available_reports
      end

      # def get_retailers_for_reports
      #   @users = Spree::User.all
      #   salesman_selected_id = @users.where(email: params[:salesman_selected]).pluck(:id)
      #   retailer_ids = VendorDetail.where(salesman_id: salesman_selected_id).pluck(:user_id)
      #   @retailer_emails = @users.where(id: retailer_ids).pluck(:email, :id)
      # end

      def convert_user_id_to_user_name(user_id)
        user_address_id = Spree::UserAddress.where("user_id IN (?)" , user_id).pluck(:address_id).max
        user_address = Spree::Address.where("id IN (?)", user_address_id)
        user_id_in_user_addresses = Spree::UserAddress.where("user_id IN (?)" , user_id).pluck(:user_id)
        if user_id_in_user_addresses.empty?
          user_id_in_user_addresses = 0
          @user_with_no_address = user_id - user_id_in_user_addresses
        end
        user_email = Spree::User.where(id: @user_with_no_address).pluck(:email,:id)
        result = user_address.all.map do |v|
          if v.company != nil && v.company != ""
            [v.company,v.id]
          elsif v.firstname != nil && v.lastname != nil
            [[v.firstname,v.lastname].join(" "),v.id] 
          end
        end
        result = result + user_email
        result.flatten
      end

      def order_condition_list
        arr = ["last 30 days","last 60 days","last 90 days"]
      end

      def list_products
        Variant.all.pluck(:sku,:id)
      end

      def list_racks
        Rack.all.pluck(:name,:id)
      end 

      def list_stock_locations
        StockLocation.all.pluck(:name,:id)
      end

      def visit
        get_retailers_for_reports

        params[:q] = {} unless params[:q]

        if params[:q][:created_at_gt].blank?
          #params[:q][:created_at_gt] = Time.current.beginning_of_month
        else
          params[:q][:created_at_gt] = begin
                                           Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                         rescue
                                           Time.current.beginning_of_month
                                         end
        end

        if params[:q] && !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = begin
                                           Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                         rescue
                                           ""
                                         end
        end

        params[:q][:s] ||= "created_at desc"
        @search = Visit.ransack(params[:q])
        @r = @search.result.includes(:order)
          if params[:q][:salesman_id_cont].nil?
            @orders = Visit.all
          elsif params[:q][:created_at_gt].present? && params[:q][:created_at_lt].present?
            from_date = params[:q][:created_at_gt].to_s(:db)
            to_date = params[:q][:created_at_lt].to_s(:db)
            if params[:q][:salesman_id_cont].present?
              retailer_id = Visit.where(salesman_id: params[:q][:salesman_id_cont]).pluck(:vendor_id).uniq    
            elsif params[:q][:vendor_id_cont].present?
              retailer_id = Visit.where(vendor_id: params[:q][:vendor_id_cont]).pluck(:vendor_id).uniq
            elsif params[:q][:salesman_id_cont].present? && params[:q][:vendor_id_cont].present?
              retailer_id = Visit.where(salesman_id: params[:q][:salesman_id_cont], vendor_id: params[:q][:vendor_id_cont]).pluck(:vendor_id).uniq
            end
            order_numbers = Order.where(user_id: retailer_id, updated_at: from_date..to_date).pluck(:number)
            @orders = Visit.where(spree_order_number: order_numbers)  
          elsif params[:q][:salesman_id_cont].present?
            retailer_id = Visit.where(salesman_id: params[:q][:salesman_id_cont]).pluck(:vendor_id).uniq
            order_numbers = Order.where(user_id: retailer_id).pluck(:number)
            @orders = Visit.where("spree_order_number IN (?)", order_numbers)
          elsif params[:q][:vendor_id_cont].present? 
            retailer_id = Visit.where(vendor_id: params[:q][:vendor_id_cont]).pluck(:vendor_id).uniq
            order_numbers = Order.where(user_id: retailer_id).pluck(:number)
            @orders = Visit.where("spree_order_number IN (?)", order_numbers)
          elsif params[:q][:salesman_id_cont].present? && params[:q][:vendor_id_cont].present? 
            retailer_id = Visit.where(salesman_id: params[:q][:salesman_id_cont], vendor_id: params[:q][:vendor_id_cont]).pluck(:vendor_id).uniq
            order_numbers = Order.where(user_id: retailer_id).pluck(:number)
            @orders = Visit.where("spree_order_number IN (?)", order_numbers)
          end
          @data = []
          @data = @orders.map do |order|
            if order.spree_order_number != nil && order.spree_order_number != "-1"
              salesman_id = convert_user_id_to_user_name(order.salesman_id).first
              retailer_id = convert_user_id_to_user_name(order.vendor_id).first
              remark = Remark.where(id: order.remark_id).pluck(:content).first
              special_instructions = Order.where(number: order.spree_order_number).pluck(:special_instructions).first

             {
              spree_order_number: order.spree_order_number,
              salesman: salesman_id,
              retailer: retailer_id,
              in_time: order.in_time,
              out_time: order.out_time,
              special_instructions: special_instructions,
              remark: remark
              }
            end
          end
          @data = @data.compact
          @data = Kaminari.paginate_array(@data).page(params[:page]).per(10)
          
      end

      def product_stock_history
        params[:q] = {} unless params[:q]

        if params[:q][:created_at_gt].blank?
          #params[:q][:created_at_gt] = Time.current.beginning_of_month
        else
          params[:q][:created_at_gt] = begin
                                           Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                         rescue
                                           Time.current.beginning_of_month
                                         end
        end

        if params[:q] && !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = begin
                                           Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                         rescue
                                           ""
                                         end
        end

        params[:q][:s] ||= "created_at desc"
        @search = StockItem.ransack(params[:q])
        @r = @search.result.includes(:variant,:stock_location)

        # if params[:q][:variant_id_cont].present? && params[:q][:stock_location_id_cont].present?
        #   product_id = params[:q][:variant_id_cont]
        #   location_id = params[:q][:stock_location_id_cont]
        #   from_date = params[:q][:created_at_gt].to_s(:db)
        #   to_date = params[:q][:created_at_lt].to_s(:db)
        #   stock_item_remarks = StockItem.where(variant_id: product_id, stock_location_id: location_id, created_at: from_date..to_date)
        # end
        @data = []
        @current_count_logic = []
        if params[:q][:variant_id_cont].present? || params[:q][:stock_location_id_cont].present?
          product_id = params[:q][:variant_id_cont]
          location_id = params[:q][:stock_location_id_cont]
          if params[:q][:created_at_gt].present? && params[:q][:created_at_lt].present?
            from_date = params[:q][:created_at_gt].to_s(:db)
            to_date = params[:q][:created_at_lt].to_s(:db)
          end
          if params[:q][:variant_id_cont].present? && params[:q][:stock_location_id_cont].present? && params[:q][:created_at_gt].present? && params[:q][:created_at_lt].present?
            stock_items = StockItem.where(variant_id: product_id, stock_location_id: location_id, updated_at: from_date..to_date)
          elsif params[:q][:variant_id_cont].present? && params[:q][:created_at_gt].present? && params[:q][:created_at_lt].present?
            stock_items = StockItem.where(variant_id: product_id, updated_at: from_date..to_date)
          elsif params[:q][:stock_location_id_cont].present? && params[:q][:created_at_gt].present? && params[:q][:created_at_lt].present?
            stock_items = StockItem.where(stock_location_id: location_id, updated_at: from_date..to_date)
          elsif params[:q][:variant_id_cont].present? && params[:q][:stock_location_id_cont].present?
            stock_items = StockItem.where(variant_id: product_id, stock_location_id: location_id)
          elsif params[:q][:variant_id_cont].present?
            stock_items = StockItem.where(variant_id: product_id)
          elsif params[:q][:stock_location_id_cont].present?

            stock_items = StockItem.where(stock_location_id: location_id)
          else
            stock_items = StockItem.where(updated_at: from_date..to_date)
          end
          stock_item_remarks =[]
          stock_items.each do |stock_item|
            stock = SpreeStockItemStockItemRemark.where(spree_stock_item_id: stock_item.id, deleted_at: nil)
            if stock.present?
              stock_item_remarks += stock_item_remarks + stock
            end 
          end
          
            @data = stock_item_remarks.map do |stock_item_remark|
              remark = Remark.where(id: stock_item_remark.remark_id).pluck(:content).first
              stock_item = StockItem.where(id: stock_item_remark.spree_stock_item_id).first
              product_name = Variant.where(id: stock_item.variant_id).pluck(:sku).first
              stock_location = StockLocation.where(id: stock_item.stock_location_id).pluck(:name).first
             
              if stock_item_remark.count_was > stock_item_remark.count
               @current_count_logic = "-" + (stock_item_remark.count_was - stock_item_remark.count).to_s
              else
                @current_count_logic = "+" + (stock_item_remark.count - stock_item_remark.count_was).to_s
              end
              {
                product_name: product_name,
                stock_location: stock_location,
                previous_stock: stock_item_remark.count_was,
                current_stock: @current_count_logic,
                remark: remark, 
                date: stock_item_remark.created_at
              }
            end
          
        else
          bulk_remark = Remark.where(action: 'Bulk Upload').pluck(:id)
          stock_item_remarks = SpreeStockItemStockItemRemark.where(remark_id: bulk_remark)
          @data = stock_item_remarks.map do |stock_item_remark|
            stock_item = StockItem.where(id: stock_item_remark.spree_stock_item_id).first
            remark = Remark.where(id: stock_item_remark.remark_id).pluck(:content).first
            if stock_item_remark.count_was > stock_item_remark.count
              @current_count_logic = "-" + (stock_item_remark.count_was - stock_item_remark.count).to_s
            else
              @current_count_logic = "+" + (stock_item_remark.count - stock_item_remark.count_was).to_s
            end
            if stock_item.present?
              product_name = Variant.where(id: stock_item.variant_id).pluck(:sku).first
              stock_location = StockLocation.where(id: stock_item.stock_location_id).pluck(:name).first

              {
                product_name: product_name,
                stock_location: stock_location,
                previous_stock: stock_item_remark.count_was,
                current_stock: @current_count_logic,
                remark: remark, 
                date: stock_item_remark.created_at
              }
            end  
          end
          @data.compact!
        end
        
        @data = Kaminari.paginate_array(@data).page(params[:page]).per(10)
      end

      def rack_stock
        params[:q] = {} unless params[:q]

        if params[:q][:created_at_gt].blank?
          #params[:q][:created_at_gt] = Time.current.beginning_of_month
        else
          params[:q][:created_at_gt] = begin
                                           Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                         rescue
                                           Time.current.beginning_of_month
                                         end
        end

        if params[:q] && !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = begin
                                           Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                         rescue
                                           ""
                                         end
        end

        params[:q][:s] ||= "created_at desc"
        @search = RackItem.ransack(params[:q])
        @r = @search.result.includes(:rack, :variant)

          product_id = params[:q][:variant_id]
          rack_id = params[:q][:rack_id]

          if params[:q][:variant_id].present?
            rack_items = RackItem.where(variant_id: product_id)
          elsif params[:q][:rack_id].present?
            rack_items = RackItem.where(rack_id: rack_id)
          elsif params[:q][:variant_id].present? && params[:q][:rack_id].present?
            rack_items = RackItem.where(variant_id: product_id, rack_id: rack_id)
          else
            rack_items = RackItem.all.includes(:rack, :variant)
          end

        # rack_items = RackItem.all.includes(:rack, :variant)
        @data = rack_items.map do |item|
          {
            rack: item.rack.stock_location.name + " - " + item.rack.name,
            design: item.variant.product.taxons.first.name + " - " + item.variant.name,
            count: item.count_on_hand
          }
        end
        @data.compact!
        @data = Kaminari.paginate_array(@data).page(params[:page]).per(10)
      end

      def product_price_history
        @data = []
        prices = Price.all
        @data = prices.map do |price|
          if price.created_at != price.updated_at
            product_name = Variant.where(id: price.variant_id).pluck(:sku).first
            if price.currency == "INR"
              amount_type = "Net Rate"
            else
              amount_type = "Due Rate"
            end
            {
              product_name: product_name,
              price: price.amount,
              amount_type: amount_type,
              updated_at: price.updated_at
            }
          end
        end
        
        @data.compact!
        @data = Kaminari.paginate_array(@data).page(params[:page]).per(10)
      end

      def order
        params[:q] = {} unless params[:q]

        if params[:q][:created_at_gt].blank?
          #params[:q][:created_at_gt] = Time.current.beginning_of_month
        else
          params[:q][:created_at_gt] = begin
                                           Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                         rescue
                                           Time.current.beginning_of_month
                                         end
        end

        if params[:q] && !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = begin
                                           Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                         rescue
                                           ""
                                         end
        end

        params[:q][:s] ||= "created_at desc"
        @search = Order.complete.ransack(params[:q])
        @a = @search.result
        @data = []
        if params[:q][:created_at_cont] == "last 30 days"
          @orders = Order.where(["created_at > ?", 30.days.ago])
        elsif params[:q][:created_at_cont] == "last 60 days"
          @orders = Order.where(["created_at > ?", 60.days.ago])
        elsif params[:q][:created_at_cont] == "last 90 days"
         @orders = Order.where(["created_at > ?", 90.days.ago])
        else
         @orders = Order.all
        end
        @data = @orders.map do |order|
          {
            order_number: order.number,
            payment_pending: order.payment_state,
            shipment_pending: order.shipment_state
          }
        end
        @data = Kaminari.paginate_array(@data).page(params[:page]).per(10)
      end
     
      @@available_reports = {}

    end
  end
end

