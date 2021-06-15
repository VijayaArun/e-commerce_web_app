module Spree

	module Admin

		ProductsController.class_eval do

			def update
				#Update set size
				update_product_details(params)
				params[:product].delete(:set_size) #Delete the key to update the attributes as update_attributes gives error when it has set_size in params
				
				
				if params[:product][:taxon_ids].present?
		          params[:product][:taxon_ids] = params[:product][:taxon_ids].split(',')
		        end
		        if params[:product][:option_type_ids].present?
		          params[:product][:option_type_ids] = params[:product][:option_type_ids].split(',')
		        end
		        if updating_variant_property_rules?
		          params[:product][:variant_property_rules_attributes].each do |_index, param_attrs|
		            param_attrs[:option_value_ids] = param_attrs[:option_value_ids].split(',')
		          end
		        end
		        invoke_callbacks(:update, :before)
		        if @object.update_attributes(permitted_resource_params)
		          invoke_callbacks(:update, :after)
		          flash[:success] = flash_message_for(@object, :successfully_updated)
		          respond_with(@object) do |format|
		            format.html { redirect_to location_after_save }
		            format.js   { render layout: false }
		          end
		        else
		          # Stops people submitting blank slugs, causing errors when they try to
		          # update the product again
		          @product.slug = @product.slug_was if @product.slug.blank?
		          invoke_callbacks(:update, :fails)
		          respond_with(@object)
		        end

			end

			def update_product_details(params)

			  	if params[:product][:set_size].present?
				  	if !@object.product_detail
				        @object.product_detail = ProductDetail.create({set_size: params[:product][:set_size]})        
				    else
				        @object.product_detail.set_size = params[:product][:set_size]
				    end
				    
				    @object.product_detail.save!
				end
			      
			end

    end
  end
end

