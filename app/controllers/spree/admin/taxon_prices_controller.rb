module Spree
  module Admin
    class TaxonPricesController < ResourceController
      helper_method :new_taxon_price_url, :collection_url, :link_to_edit, :link_to_delete

      def index
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        @permalink_part = @taxon.permalink.split("/").last
        @prices = TaxonPrice.where(:taxon_id => @taxon.id)
      end

      def new
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        @permalink_part = @taxon.permalink.split("/").last
      end

      def edit
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        @permalink_part = @taxon.permalink.split("/").last
        @prices = TaxonPrice.find(params[:id])
      end

      def update
        @prices = TaxonPrice.find(params[:id])
        if @prices.update_attributes(taxon_price_params)
          flash[:success] = Spree.t(:account_updated)

          redirect_to admin_taxonomy_taxon_taxon_prices_path
        else
          render 'edit'
        end
      end

      def new_taxon_price_url
        url = '/admin/taxonomies/'+ @taxonomy.id.to_s + '/taxons/' + @taxon.id.to_s + '/taxon_prices/new'
      end

      def collection_url
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        if !params["taxon_id"].is_a?(Integer) && !params["taxon_price"].nil?
          @taxon = @taxonomy.taxons.find(params["taxon_price"]["taxon_id"])
        else
          @taxon = @taxonomy.taxons.find(params[:taxon_id])
        end
        url = '/admin/taxonomies/'+ @taxonomy.id.to_s + '/taxons/' + @taxon.id.to_s + '/taxon_prices'
      end

      def collection 
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
        @collection = TaxonPrice.where(:taxon_id => @taxon.id)
      end
      
      def link_to_edit(resource, options = {})
        url = '/admin/taxonomies/'+ @taxonomy.id.to_s + '/taxons/' + @taxon.id.to_s + '/taxon_prices/' + resource[:id].to_s + '/edit'
        options[:data] = { action: 'edit' }
        view_context.link_to_with_icon('edit', Spree.t('actions.edit'), url, options)
      end

      def link_to_delete(resource, options = {})
        url = '/admin/taxonomies/'+ @taxonomy.id.to_s + '/taxons/' + @taxon.id.to_s + '/taxon_prices/' + resource[:id].to_s
        name = options[:name] || Spree.t('actions.delete')
        options[:class] = "delete-resource"
        options[:data] = { confirm: Spree.t(:are_you_sure), action: 'remove' }
        view_context.link_to_with_icon 'trash', name, url, options
      end

      def taxon_details
        @taxons = []
        if request.post? 
          edited_taxon_info = params[:taxon_info]
          new_data = JSON.parse edited_taxon_info
          id = 1;
          new_data.each do |taxon|
            new_taxon_data = {
              name: taxon["columns"][1],
              image: taxon["columns"][5], 
              taxons: taxon["columns"][4], 
              net_rate: taxon["columns"][3], 
              due_rate: taxon["columns"][2], 
              flag: taxon["columns"][0],
              set_size: taxon["columns"][7],
              available_on: taxon["columns"][6]
            } 
            @taxons << {
              id: id,
              values: new_taxon_data
            }
            id = id + 1
          end
        else
          @taxons = Spree::Taxon.all
          taxon_prices = Spree::TaxonPrice.all
          id = 1
          @taxons.each_with_index do |taxon, taxon_index|
            net_rate = nil
            due_rate = nil
            taxon_price_net_rate = taxon_prices.where(taxon_id: taxon.id, currency: "INR").first
            taxon_price_due_rate = taxon_prices.where(taxon_id: taxon.id, currency: "INR2").first
            if taxon_price_net_rate.present? && taxon_price_due_rate.present?
              if taxon_price_net_rate.taxon_id == taxon.id && taxon_price_due_rate.taxon_id == taxon.id
                net_rate = taxon_price_net_rate.amount 
                due_rate = taxon_price_due_rate.amount 
              end
            end
            @taxons[taxon_index] = {
              id: taxon.id,
              values: {
                name: taxon[:name],
                net_rate: net_rate,
                due_rate: due_rate
              }
            }
            id = id + 1
          end
        end
      end

      private
      def taxon_price_params
        {
          price: params[:taxon_price][:price]
        }
      end
    end
  end
end
