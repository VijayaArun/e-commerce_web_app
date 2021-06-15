class Spree::VendorController < ApplicationController

  layout '/layouts/vendor'
  before_action :require_login
 include Spree::Core::ControllerHelpers::Auth
 include UserHelper
 include VendorHelper
 helper Spree::BaseHelper
 include Spree::Core::ControllerHelpers::StrongParameters

      #Added for using helper method try_spree_current_user

    def index
       redirect_to('/vendor/select')
    end

    def login
    	#sign_out_all_scopes

      if params["vendor-email"].blank?
        redirect_to('/vendor')
      else
      	sign_out spree_current_user #Devise/Controllers/sign_in_out.rb
      	sign_in (Spree::User.where(:email => params["vendor-email"]))[0]
        session[:currency] = "INR"
        redirect_to('/')
      end
    end

    def select_vendor
    end

    def view_reports
    end

    def add_vendor
        if request.get?
            @user = Spree.user_class.new
            render :add_vendor
        else
            action_name = "create"
            current_user_id = spree_current_user[:id]
            if params[:user][:ship_address_attributes].nil?
              params[:user][:ship_address_attributes] = params[:user][:bill_address_attributes]
            end
            errors = create_vendor(current_user_id)
            if errors.nil?
                flash[:success] = Spree.t(:created_successfully)
                redirect_to("/vendor/select")
            else
                render :add_vendor
            end
        end
    end
 private

  def logged_in?
      spree_current_user != nil
   end

  def require_login
      unless logged_in?
          redirect_to spree_login_path
      else
          if !try_spree_current_user.try(:has_spree_role?, ENV["ROLE_SALESMAN"])
              redirect_to("/")
          end
      end
  end


end
