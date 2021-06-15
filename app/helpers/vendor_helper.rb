module VendorHelper
	def collection_url
    "select"
	end

	def list_vendors
		@users = Spree::User.all
		@current_salesman_users = VendorDetail.where(salesman_id: spree_current_user).pluck(:user_id)
		user_address_id = Spree::UserAddress.where("user_id IN (?)" , @current_salesman_users).pluck(:user_id)
		@vendors_with_addresses = @users.where("id IN (?)", user_address_id)
		@vendor_id_in_user_addresses = Spree::UserAddress.where("user_id IN (?)" , @current_salesman_users).pluck(:user_id)
		@user_with_no_address = @current_salesman_users - @vendor_id_in_user_addresses
		user_email = @users.where(id: @user_with_no_address).map do |v|
        [v.email, v.email, {'data-outstanding' => v.display_total_outstanding_amount.to_html }]
		end

		dropdown_result = @vendors_with_addresses.map do |v|  
			vendor_address_id = Spree::UserAddress.find_by(user_id: v.id).address_id
			address = Spree::Address.find(vendor_address_id)
			if address.company != nil && address.company != ""
				[address.company, v.email, {'data-outstanding' => v.display_total_outstanding_amount.to_html }]
			elsif address.firstname != nil && address.lastname != nil
				[[address.firstname, address.lastname].join(" "), v.email, {'data-outstanding' => v.display_total_outstanding_amount.to_html }] 
			end
		end 
		dropdown_result = dropdown_result + user_email
		dropdown_result
	end
	
	def get_retailers_for_reports
        @users = Spree::User.all
        user_with_role = Spree::Role.where("name IN (?)", ENV["ROLE_VENDOR"]).pluck(:id)
        @retailer_addresses = @users.where(id: Spree::RoleUser.where(role_id: user_with_role).pluck(:user_id))
        retailer_id = @users.where(id: Spree::RoleUser.where(role_id: user_with_role).pluck(:user_id)).pluck(:id)
        retailer_address_id = Spree::UserAddress.where("user_id IN (?)" , retailer_id).pluck(:address_id)
        @retailer_addresses = Spree::Address.where("id IN (?)", retailer_address_id)
        
        retailer_id_in_user_addresses = Spree::UserAddress.where("user_id IN (?)" , retailer_id).pluck(:user_id)
        retailer_with_no_address = retailer_id - retailer_id_in_user_addresses
        retailer_email = @users.where(id: retailer_with_no_address).pluck(:email,:id)
        @dropdown_result = @retailer_addresses.all.map do |v|
            user_id = Spree::UserAddress.where(address_id: v.id).pluck(:user_id)
            if v.company != nil && v.company != ""
                [v.company,user_id.first]
            elsif v.firstname != nil && v.lastname != nil
              [[v.firstname,v.lastname].join(" "),user_id.first]
            end
    	  end
    	@dropdown_result = @dropdown_result + retailer_email
    	return @dropdown_result
    end

	def create_vendor(current_user_id)
	    @user = Spree.user_class.new(new_user_params)
      random_password = generate_password(15)
      generated_email = @user.email.empty? ? generate_email(current_user_id): @user.email
	    @user.assign_attributes(email: generated_email, password: random_password , password_confirmation: random_password , created_by_id: current_user_id)

	    if @user.save
          @user[:ship_address_id] = @user[:bill_address_id]
          @user.generate_spree_api_key!
          user_id = @user[:id]
          @set_role = Spree::RoleUser.all
          role_id = Spree::Role.where("name IN (?)", ENV["ROLE_VENDOR"]).pluck(:id)
          @set_role = @set_role.create(role_id: role_id[0] ,user_id: user_id)
          gstnumber = params[:user][:vendor_detail_attributes][:gst_number]
          @vendor = VendorDetail.create(user_id: user_id , salesman_id: current_user_id, gst_number: gstnumber)
          return nil
      else
          return @user.errors
	    end
	  end
end
