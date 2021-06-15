module Spree
  module Admin
    TaxonsController.class_eval do
      helper_method  :collection_url, :taxon_information_for_edit_form, :link_to_edit, :link_to_delete, :product_information_for_edit_form, :sub_category_list, :display_product_names_for_multiple_products, :racks_list, :top_sub_category_list
      respond_to :html, :js

      def new_sub_category
        
        if request.get? 
          @taxon = Taxon.new
          @taxons = Spree::Taxon.all
          @taxon_parent_id = params[:parent_id]
          #taxon_information_for_edit_form(@taxon)
        else
          action_name = "create" 
          parent_id = params[:taxon][:taxon_ids]
          taxonomy_id = Taxon.where(id: parent_id).pluck(:taxonomy_id).first
          # Updating is_item column internally
          # @taxons = Classification.all.pluck(:taxon_id)
          # taxons_with_product = Taxon.where("id IN (?)", @taxons).pluck(:id)
          # is_item = Taxon.where("id IN (?)", taxons_with_product).update_all(is_item: true)
          new_sub_category_name = params[:taxon][:name]
          taxon_names = Taxon.where(parent_id: parent_id).pluck(:name)
          if !taxon_names.include?(new_sub_category_name)
            @taxon = Taxon.new(name: params[:taxon][:name],position: 0,parent_id: parent_id,taxonomy_id: taxonomy_id)
            if @taxon.save   
              @taxon.child_index = 0
              @taxon.save
              flash[:success] = Spree.t(:sub_category_created_successfully)
              redirect_to admin_taxonomy_category_tree_path(taxonomy_id)
            else 
              @taxon = Taxon.new 
              render 'new_sub_category'
            end
          else
            @taxon = Taxon.new 
            @taxons = Spree::Taxon.all
            flash[:error] = Spree.t(:please_give_unique_sub_category_name)
            render 'new_sub_category'
          end
        end
      end

      
      def sub_category_tree
        @taxon = Taxon.find(params[:taxon_id])
      end

      def sub_category_list
        sub_category = Taxon.sub_categories.where.not(id: params[:id]).where.not(parent_id: nil)
      end

      def top_sub_category_list
        top_sub_category = Taxon.sub_categories.where.not(id: params[:id]).where(parent_id: nil)
      end

      def racks_list
        Spree::Rack.all
      end

      def new_item
        if request.get? 
          @taxon = Taxon.new
          @taxons = Spree::Taxon.all
          @taxon_parent_id = params[:parent_id]
          @taxon_parent_id != nil ? @top_taxon_id = Spree::Taxon.find(@taxon_parent_id).parent.id : @top_taxon_id = params[:parent_id]
        else
          action_name = "create" 
          parent_id = params[:taxon][:taxon_ids]
          taxonomy_id = Taxon.where(id: parent_id).pluck(:taxonomy_id).first
          new_taxon_name = params[:taxon][:name]
          taxon_names = Taxon.all.pluck(:name)
          if !taxon_names.include?(new_taxon_name)
            @taxon = Spree::Taxon.new(name: params[:taxon][:name], position: 0, parent_id: parent_id, taxonomy_id: taxonomy_id, is_item: 1)
            
            if @taxon.save   
              @taxon.child_index = 0
              @taxon.save
              taxon_id = @taxon.id
              taxon_price_net_rate = TaxonPrice.new(taxon_id: taxon_id, amount: params[:net_rate], currency: "INR",effective_from: params[:net_rate_effective_from])
              taxon_price_due_rate = Spree::TaxonPrice.new(taxon_id: taxon_id, amount: params[:due_rate], currency: "INR2",effective_from: params[:due_rate_effective_from])
              taxon_price_net_rate.save
              taxon_price_due_rate.save
              flash[:success] = Spree.t(:taxon_created_successfully)
              redirect_to edit_admin_taxonomy_taxon_path(taxonomy_id,taxon_id)
            else 
              @taxon = Taxon.new 
              render 'new_item'
            end
          else
            @taxon = Taxon.new 
            @taxons = Spree::Taxon.all
            flash[:error] = Spree.t(:please_give_unique_taxon_name)
            render 'new_item'
          end
        end
      end

      #current_product_name parameter is given becasue of update action
      def check_for_unique_product_names(product_name,current_product_name,taxon_id)
        if (product_name == current_product_name)
          return true
        else
          product_id = Classification.where(taxon_id: taxon_id).pluck(:product_id)
          product_names = Product.where(id: product_id).pluck(:name)
          if !product_names.collect {|e| e.downcase}.include? product_name.downcase
            return true
          else
            return false
          end
        end
      end

      def delete_multiple_products
        message = {}
        variant_ids = params[:variant_ids]
        unless (variant_ids.nil?)
          total_products = variant_ids.length
          deleted_products = 0
          variant_ids.each {|variant_id|
            product = Variant.find(variant_id).product
            begin
              product.destroy
              deleted_products += 1
            rescue
              message[:error] = Spree.t(:some_products_not_deleted)
            end
          }
          if total_products == deleted_products
            message[:success] = Spree.t(:deleted_selected_products)
          elsif deleted_products > 0
            message[:success] = Spree.t(:few_deleted_products)
          elsif deleted_products == 0
            message[:error] = Spree.t(:no_deleted_products)
          end
        else
          message[:error] = Spree.t(:no_deleted_products)
        end
        render :json => message
      end

      def new_product
        @taxon = Taxon.find(params[:id])
        @taxonomy = Taxon.find(@taxon.id).taxonomy_id
        @new_product_name = generate_product_name(@taxon)
        if request.get?
          @product = Product.new
          @collection = StockLocation.all
        else
          if params[:product][:name].present?
            @new_product_name = params[:product][:name]
          end
          parent_id = @taxon.parent_id
          taxonomy_name = Taxonomy.find(@taxonomy).name
          parent_name = Taxon.find(parent_id).name
          sku = taxonomy_name + "-" +  @taxon.name + "-" + @new_product_name
          master_price = TaxonPrice.where(taxon_id: @taxon.id,currency: "INR").pluck(:amount).first
          taxon_price_due_rate = Spree::TaxonPrice.where(taxon_id: @taxon.id,currency: "INR2").first.amount
          if check_for_unique_product_names(@new_product_name,nil,@taxon.id) == true
            @product = Product.new(name: @new_product_name, shipping_category_id: 1, tax_category_id: 1 , price: master_price, taxon_ids: @taxon.id, sku: sku, slug: sku,available_on: params[:product][:available_on])
            if @product.save
              product_details = ProductDetail.new(set_size: params[:product][:set_size],product_id: @product.id)
              product_details.save
              variant = Spree::Variant.find_by(product_id: @product.id)
              due_rate = Spree::Price.new(variant_id: variant.id ,amount: taxon_price_due_rate ,currency: "INR2")
              due_rate.save
              stock_locations = StockLocation.all
              stock_locations.each do |stock_location|
                stock_location.racks.each do |rack|
                  rack_stock = params[rack.name + "_" + stock_location.name + "_total_stock"].to_i
                  if rack_stock > 0
                    current_location_stock = variant.stock_items.where(stock_location_id: stock_location.id).first.count_on_hand
                    variant.stock_items.where(stock_location_id: stock_location.id).update_all(count_on_hand: current_location_stock + rack_stock)
                    rack.rack_items.find_or_create_by(variant_id: variant.id).update(count_on_hand: rack_stock)
                  end
                end
              end
              if params[:product][:images].present?
                images = Image.new(viewable_id: variant.id, viewable_type: "Spree::Variant")
                images.attachment = params[:product][:images][:attachment]
                images.save
              end
              flash[:success] = Spree.t(:product_added_successfully)
              respond_to do |format|
                format.html
                format.js {}
              end
            end
          else
              flash[:error] = Spree.t(:please_give_unique_product_name)
              respond_to do |format|
                format.html
                format.js {}
              end
          end
          @collection = StockLocation.all
        end
      end

      def generate_product_name(taxon, unsaved_product_names = [])

        product_id = Classification.where(taxon_id: taxon.id).pluck(:product_id)
        product_names = Product.where(id: product_id).pluck(:name)
        product_names = product_names.to_a + unsaved_product_names
        last_product = product_names.last
        if last_product.present?
          if /^[\d]+(\.[\d]+){0,1}$/ === last_product 
            arr = [*('1'..'50')]
            new_product_name =  arr.first
            while product_names.collect {|e| e.to_i.to_s}.include? new_product_name do
              new_product_name = new_product_name.next
            end
          else
            arr = [*('A'..'Z')]
            new_product_name =  arr.first
            while product_names.collect {|e| e.downcase}.include? new_product_name.downcase do
              new_product_name = new_product_name.next
            end
          end
        else
          new_product_name = "1"
        end
        new_product_name
      end

      def get_product_names
        @taxon = Taxon.find(params[:id])
        @product_names = display_product_names_for_multiple_products(params[:no_of_products],@taxon)
      end

      def new_multiple_product
        @max_product_numbers = ENV["MAX_NUMBER_OF_PRODUCT"].to_i
        @taxon = Taxon.find(params[:id])
        @taxonomy = Taxon.find(@taxon.id).taxonomy_id
        @new_product_name = generate_product_name(@taxon)
        if request.get?
          @product = Product.new
          @collection = StockLocation.all
        else
          params[:product].each do |index, prod|
            if prod["name"].present?
              @new_product_name = prod["name"]
            elsif prod["attachment"].present?
              @new_product_name = generate_product_name(@taxon)
            else
              next
            end
            parent_id = @taxon.parent_id
            taxonomy_name = Taxonomy.find(@taxonomy).name
            parent_name = Taxon.find(parent_id).name
            sku = taxonomy_name + "-" +  @taxon.name + "-" + @new_product_name
            master_price = TaxonPrice.where(taxon_id: @taxon.id,currency: "INR").pluck(:amount).first
            taxon_price_due_rate = Spree::TaxonPrice.where(taxon_id: @taxon.id,currency: "INR2").first.amount
            if check_for_unique_product_names(@new_product_name,nil,@taxon.id) == true
              @product = Product.new(name: @new_product_name, shipping_category_id: 1, tax_category_id: 1 , price: master_price, taxon_ids: @taxon.id, sku: sku, slug: sku,available_on: prod["available_on"])
              if @product.save
                product_details = ProductDetail.new(set_size: prod["set_size"],product_id: @product.id)
                product_details.save
                variant = Spree::Variant.find_by(product_id: @product.id)
                due_rate = Spree::Price.new(variant_id: variant.id ,amount: taxon_price_due_rate ,currency: "INR2")
                due_rate.save
                stock_locations = StockLocation.all
                stock_locations.each do |stock_location|
                  stock_location.racks.each do |rack|
                    rack_stock = params[rack.name + "_" + stock_location.name + "_total_stock_" + index.to_s].to_i
                    if rack_stock > 0
                      current_location_stock = variant.stock_items.where(stock_location_id: stock_location.id).first.count_on_hand
                      variant.stock_items.where(stock_location_id: stock_location.id).update_all(count_on_hand: current_location_stock + rack_stock)
                      rack.rack_items.find_or_create_by(variant_id: variant.id).update(count_on_hand: rack_stock)
                    end
                  end
                end
                if prod["attachment"].present?
                  images = Image.new(viewable_id: variant.id, viewable_type: "Spree::Variant")
                  images.attachment = prod["attachment"]
                  images.save
                end
                flash[:success] = Spree.t(:product_added_successfully)
                respond_to do |format|
                  format.html
                  format.js {}
                end
              end
            else
                flash[:error] = Spree.t(:please_give_unique_product_name)
                respond_to do |format|
                  format.html
                  format.js {}
                end
            end
            @collection = StockLocation.all
          end
        end
      end

      def display_product_names_for_multiple_products(no_of_products,taxon)
        product_names = []
        no_of_products.to_i.times do
          product_names << generate_product_name(taxon, product_names)
        end
        product_names.join(",").to_s.gsub('"','')
      end

      def product_information_for_edit_form(product)
        @image = product.display_image
        @new_product_name = product.name
        @set_size = ProductDetail.where(product_id: product.id).pluck(:set_size).first
        if @set_size == nil
          @set_size = 4
        end
        @available_on = product.available_on
        @collection = StockLocation.all
        @racks_stock = {}
        product.master.rack_items.each do |rack_item|
          if rack_item.count_on_hand > 0
            @racks_stock[rack_item.rack.name +  "_" + rack_item.rack.stock_location.name + "_total_stock"] = rack_item.count_on_hand
          end
        end
      end

      def edit_product
        @taxonomy_id = params[:taxonomy_id]
        @taxon_id = params[:taxon_id]
        @product_id = params[:id]
        @product = Product.find(params[:id])
        product_information_for_edit_form(@product)
      end

      def update_product
        @taxonomy_id = params[:taxonomy_id]
        @taxon_id = params[:taxon_id]
        @product_id = params[:id]
        @product = Product.find(params[:id])
        product_information_for_edit_form(@product)
        if check_for_unique_product_names(params[:product][:name], @product.name,@taxon_id) == true
          if @product.update_attributes(new_product_params)
            ProductDetail.where(product_id: params[:id]).update_all(set_size: params[:product][:set_size])
            variant_id = Variant.find_by(product_id: @product.id).id
            if params[:product][:images].present?
              attachment = params[:product][:images][:attachment]
              variant_img = Image.where(viewable_id: variant_id).first
              if variant_img.present?
                delete_image = Spree::Image.destroy(variant_img.id)
              end
              images = Spree::Image.new(viewable_id: variant_id, viewable_type: "Spree::Variant")
              images.attachment = attachment
              images.save
            end
            @collection.each do |stock_location|
              current_location_stock = 0
              rack_stock_found = false
              stock_location.racks.each do |rack|
                rack_stock = params[rack.name + "_" + stock_location.name + "_total_stock"].to_i
                rack_stock_found = true
                current_location_stock += rack_stock
                rack.rack_items.find_or_create_by(variant_id: variant_id).update(count_on_hand: rack_stock)
              end
              if rack_stock_found
                @product.master.stock_items.where(stock_location_id: stock_location.id).update_all(count_on_hand: current_location_stock)
              end
            end
            flash[:success] = Spree.t(:product_updated_successfully)
            redirect_to(edit_admin_taxonomy_taxon_path(@taxonomy_id,@taxon_id))
          end
        else
          flash[:error] = Spree.t(:please_give_unique_product_name)
          respond_to do |format|
            format.html { render 'edit_product'}
            format.js { render 'edit_product'}
          end
        end
      end

      # def edit_new_item
      #   @taxon = Taxon.find(params[:id])
      #   taxon_information_for_edit_form(@taxon)
      #   @taxons = Spree::Taxon.all
      # end

      # def update_new_item
      #   @taxon = Taxon.find(params[:id])
      #   @taxons = Spree::Taxon.all
      #   if @taxon.update_attributes(new_item_params)
      #     TaxonPrice.where(taxon_id: @taxon.id, currency: "INR").update_all(amount: params[:net_rate])
      #     TaxonPrice.where(taxon_id: @taxon.id, currency: "INR2").update_all(amount: params[:due_rate])
      #     flash[:success] = Spree.t(:taxon_updated_successfully)
      #     redirect_to edit_new_item_admin_taxon_path(@taxon.id)
      #   else
      #     redirect_to edit_new_item_admin_taxon_path(@taxon.id)
      #   end
      # end

      def collection_url
        if params[:action] == "new_product" || params[:action] == "new_multiple_product"
          taxon_id = params[:id]
          taxonomy_id = Taxon.find(taxon_id).taxonomy_id
          edit_admin_taxonomy_taxon_path(taxonomy_id,taxon_id)
        elsif params[:action] == "new_item"
          admin_taxonomies_path
        elsif params[:action] == "new_sub_category"
          admin_taxonomies_path
          #admin_taxonomy_category_tree_path(taxonomy_id)
        elsif params[:action] == "edit_product" 
          taxon_id = params[:taxon_id]
          taxonomy_id = Taxon.find(taxon_id).taxonomy_id
          edit_admin_taxonomy_taxon_path(taxonomy_id,taxon_id)
        end
      end

      def collection 
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        product_id = Classification.where(taxon_id: @taxon.id).pluck(:product_id)
        @collection = Product.where(id: product_id)
      end

      def link_to_edit(resource, options = {})
        @product_id = Variant.where(sku: resource[:sku]).pluck(:product_id).first
        url = '/admin/taxonomies/'+ @taxonomy.id.to_s + '/taxons/' + @taxon.id.to_s + '/products/' + @product_id.to_s + '/edit_product'
        options[:data] = { action: 'edit' }
        view_context.link_to_with_icon('edit', Spree.t('actions.edit'), url, options)
      end

      def link_to_delete(resource, options = {})
        slug = Product.find(@product_id).slug
        url = '/admin/products/' + slug.to_s
        name = options[:name] || Spree.t('actions.delete')
        options[:class] = "delete-resource"
        options[:data] = { confirm: Spree.t(:are_you_sure), action: 'remove' }
        view_context.link_to_with_icon 'trash', name, url, options
      end

      def taxon_information_for_edit_form(taxon)
        current_taxon = Taxon.find(taxon.id)
        @taxon_parent_id = current_taxon.parent_id
        @net_rate = TaxonPrice.where(taxon_id: taxon, currency: "INR").pluck(:amount).first
        @due_rate = TaxonPrice.where(taxon_id: taxon, currency: "INR2").pluck(:amount).first
        @net_rate_effective_from = TaxonPrice.where(taxon_id: taxon, currency: "INR").pluck(:effective_from).first
        @due_rate_effective_from = TaxonPrice.where(taxon_id: taxon, currency: "INR2").pluck(:effective_from).first
      end

      def edit
        
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxons = Taxon.all
        @taxon = @taxonomy.taxons.find(params[:id])
        #@disable_taxon = @taxon != nil ? true : false
        taxon_information_for_edit_form(@taxon)
        @permalink_part = @taxon.permalink.split("/").last
        @products = @taxon.products
        @collection = []
        @grand_total_stock = 0
        @collection = @products.map do |product|
          set_size = ProductDetail.where(product_id: product.id).pluck(:set_size).first
          variant_id = Variant.where(product_id: product.id)
          rack_items = RackItem.where(variant_id: variant_id)
          racks = []
          rack_items.each do |rack_item|
            if (rack_item.count_on_hand > 0)
              rack = Spree::Rack.where(id: rack_item.rack_id).first
              racks << rack.name + " : " + rack_item.count_on_hand.to_s
            end
          end
          racks = racks.join(", ").to_s.gsub('"','')
          total_stock = StockItem.where(variant_id: variant_id).pluck(:count_on_hand).sum
          @grand_total_stock = @grand_total_stock + total_stock
          {
            sku: product.sku,
            image: product.display_image.attachment(:mini),
            large_image: product.display_image.attachment(:large),
            name: product.name,
            set_size: set_size,
            total_stock: total_stock,
            racks: racks,
            variant_id: variant_id[0].id
          }
        end
        
      end

      def update
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:id])
        @taxons = Spree::Taxon.all
        if @taxon.update_attributes(new_item_params)
          Taxon.where(id: params[:id]).update_all(parent_id: params[:taxon][:taxon_ids])
          if @taxon.is_item 
            net_rate_taxon_price_id = TaxonPrice.where(taxon_id: @taxon.id, currency: "INR").pluck(:id).first
            TaxonPrice.update(net_rate_taxon_price_id ,amount: params[:net_rate],effective_from: params[:net_rate_effective_from])
            due_rate_taxon_price_id = TaxonPrice.where(taxon_id: @taxon.id, currency: "INR2").pluck(:id).first
            TaxonPrice.update(due_rate_taxon_price_id,amount: params[:due_rate],effective_from: params[:due_rate_effective_from])
          end
          flash[:success] = flash_message_for(@taxon, :successfully_updated)
          redirect_to edit_admin_taxonomy_taxon_path(@taxonomy.id,@taxon.id)
        else
          redirect_to edit_new_item_admin_taxon_path(@taxon.id)
        end
        parent_id = params[:taxon][:parent_id]
        new_position = params[:taxon][:position]

        # is_item = nil
        # if @taxon.is_item
        #   is_item = true
        # else
        #   is_item = false
        # end

        if parent_id
          @taxon.parent = Taxon.find(parent_id.to_i)
        end

        if new_position
          @taxon.child_index = new_position.to_i
        end

        if params[:permalink_part]
          @taxon.permalink_part = params[:permalink_part].to_s
        end

        # @taxon.assign_attributes(taxon_params)

        # if @taxon.save
        #   flash[:success] = flash_message_for(@taxon, :successfully_updated)
        # end

        # respond_with(@taxon) do |format|
        #   format.html { redirect_to edit_admin_taxonomy_url(@taxonomy) }
        # end
      end

      private

      def new_item_params
        params.require(:taxon).permit(:net_rate, :due_rate, :name, :parent_id)
      end

      def new_product_params
        params.require(:product).permit(:name, :available_on, :attachment, :image)
      end
    end
  end
end