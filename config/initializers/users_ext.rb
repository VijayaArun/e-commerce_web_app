module UsersControllerOverrides
  def self.included base
    base.class_eval do
      include UserHelper

      def user_params
        new_user_params
      end

      def user_vendor_params
        unless params[:user][:vendor_detail_attributes].nil?
          attributes = permitted_vendor_detail_attributes
          params[:user].require(:vendor_detail_attributes).permit(attributes) 
        else  
          {}
        end        
      end

      def user_salesman_params
        unless params[:user][:salesman_detail_attributes].nil?
          params[:user].require(:salesman_detail_attributes).permit([:identifier])
        else
          {}
        end 
        
      end

      def create
        current_user_id = spree_current_user[:id]
        @user = Spree.user_class.new(user_params)
        @user[:created_by_id] = current_user_id
        role = Spree::Role.where(id: user_params[:spree_role_ids]).first.name

        # Filling identifier for salesman here as it is required while save
        if role == ENV["ROLE_SALESMAN"]
          salesman_details_attributes = user_salesman_params
          if salesman_details_attributes["identifier"].nil?
            salesman_details_attributes["identifier"] = @user.set_uniq_identifier(@user.email)
          end
          @user.salesman_details = SalesmanDetails.new(identifier: salesman_details_attributes["identifier"].upcase)
        end

        if @user.save
          @user.generate_spree_api_key!
          set_roles
          set_stock_locations
          
          if role == ENV["ROLE_VENDOR"]
            salesman_id = params[:user][:vendor_detail_attributes][:salesman_id] || @user[:created_by_id]
            random_password = generate_password(15)
            @user.assign_attributes(password: random_password, password_confirmation: random_password , created_by_id: salesman_id)
            gstnumber = params[:user][:vendor_detail_attributes][:gst_number]
            @user.vendor_detail = VendorDetail.new(:salesman_id => salesman_id, :gst_number => gstnumber)
          end
          flash[:success] = Spree.t(:created_successfully)
          redirect_to edit_admin_user_url(@user)
        else
          load_roles
          load_stock_locations

          render :new, status: :unprocessable_entity
        end
      end

      def update
        load_roles
        user_params_updated = user_params
        if @user.update_attributes(user_params_updated)
          current_user_id = spree_current_user[:id]
          set_roles
          set_stock_locations
          update_role_specific_stuff(user_vendor_params, user_salesman_params)
          flash[:success] = Spree.t(:account_updated)
          redirect_to edit_admin_user_url(@user)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def update_role_specific_stuff(vendor_detail_attributes, salesman_details_attributes)
        user_id = @user[:id]
        if @user.role.name == ENV["ROLE_VENDOR"]
          @user.salesman_details.destroy! if @user.salesman_details.present?
          if @user.vendor_detail.nil?
            @user.vendor_detail = VendorDetail.new(salesman_id: vendor_detail_attributes["salesman_id"],
              gst_number: vendor_detail_attributes["gst_number"])
          else
            @user.vendor_detail.update_attributes(:salesman_id => vendor_detail_attributes["salesman_id"],
              :gst_number => vendor_detail_attributes["gst_number"])
          end
        elsif @user.role.name == ENV["ROLE_SALESMAN"]
          @user.vendor_detail.really_destroy! if @user.vendor_detail.present?
          if salesman_details_attributes["identifier"].nil?
            salesman_details_attributes["identifier"] = @user.set_uniq_identifier(@user.email)
          end
          if @user.salesman_details.nil?
            @user.salesman_details = SalesmanDetails.new(identifier: salesman_details_attributes["identifier"])
          else
            @user.salesman_details.update_attributes(:identifier => salesman_details_attributes["identifier"])
          end
        else
          @user.vendor_detail.really_destroy! if @user.vendor_detail.present?
          @user.salesman_details.destroy! if @user.salesman_details.present?
        end
        @user.save
      end

      def addresses
        if request.put?
          params[:user][:bill_address_attributes] = params[:user][:ship_address_attributes]
          if @user.update_attributes(user_params)

            flash.now[:success] = Spree.t(:account_updated)
            redirect_to addresses_admin_user_url(@user)
          else
            render :addresses, status: :unprocessable_entity
          end
        end
      end
    end
  end
end

Spree::Admin::UsersController.send(:include, UsersControllerOverrides)
