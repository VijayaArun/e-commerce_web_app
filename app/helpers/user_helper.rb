module UserHelper
    def new_user_params
        attributes = permitted_user_attributes

        if action_name == "create" || action_name == "add_vendor" || can?(:update_email, @user)
            attributes |= [:email]
        end

        if can? :manage, Spree::Role
            attributes += [{ spree_role_ids: [] }]
        end
        attributes += [:created_by_id]
        params.require(:user).permit(attributes)
    end

    def generate_password(length)
        chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        password = ''
        length.times { password << chars[rand(chars.size)] }
        password
    end

    def generate_email(salesman_user_id)
        email = params[:user][:ship_address_attributes][:company].gsub(/[[:space:]]/, '') + '_' + SalesmanDetails.where(:user_id => salesman_user_id)[0].identifier + '_' + Time.now.strftime("%d%m%Y%H%M%S")
        email.to_s.to_s.gsub(/[^a-zA-Z0-9_]/, "")
        email = email + "@" + Spree.t(:email_postfix_domain) + ".com"
        email
    end

    def created_by
        unless @user.vendor_detail.nil? 
            @user.vendor_detail.salesman_id  
        else 
            @user.created_by_id
        end
    end

   def list_salesmen
    @users = Spree::User.all
    user_with_role = Spree::Role.where("name IN (?)", 'salesman' ).pluck(:id)
    @vendor_linked_to = @users.where(id: Spree::RoleUser.where(role_id: user_with_role).pluck(:user_id))
    @salesman_id = @users.where(id: Spree::RoleUser.where(role_id: user_with_role).pluck(:user_id)).pluck(:id)
    user_address_id = Spree::UserAddress.where("user_id IN (?)" , @salesman_id).pluck(:address_id)
    @vendor_linked_to = Spree::Address.where("id IN (?)", user_address_id)
   
    @salesman_id_in_user_addresses = Spree::UserAddress.where("user_id IN (?)" , @salesman_id).pluck(:user_id)
    @user_with_no_address = @salesman_id - @salesman_id_in_user_addresses
    @user_email = @users.where(id: @user_with_no_address).pluck(:email,:id)
    @dropdown_result = @vendor_linked_to.all.map do |v|
      if v.company != nil && v.company != ""
        [v.company,v.id]
      elsif v.firstname != nil && v.lastname != nil
        [[v.firstname,v.lastname].join(" "),v.id] 
      end
    end 
    @dropdown_result = @dropdown_result + @user_email
    return @dropdown_result
  end

    def list_user_details(user)
        user_address_id = Spree::UserAddress.where(user_id: user.id).pluck(:address_id)
        user_address = Spree::Address.where(id: user_address_id)
        @result = []
        user_address.each do |a|
            if a.company.present?
                @result << a.company
            elsif a.firstname.present? && a.lastname.present?
                @result << [a.firstname,a.lastname].join(" ") 
            else
                @result << user.email
            end
        end
        @result.first
    end
    
end

    