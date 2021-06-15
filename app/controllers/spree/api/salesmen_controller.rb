class Spree::Api::SalesmenController < Spree::Api::BaseController
include Spree::AuthenticationHelpers
		 	#Api to get salesmen details
 	def index
        roles = Spree::Role.where(name: ENV["ROLE_SALESMAN"])
        role_user_ids = Spree::RoleUser.where(role: roles).pluck(:user_id)
        if api_key.blank?
          user_id = spree_current_user[:id]
          user = Spree::User.find_by(id: user_id)
        else
          user = Spree::User.find_by(spree_api_key: api_key)
          user_id = user.id
        end
        if (user.role.name == ENV["ROLE_ADMIN"])
          @users = Spree::User.where(id: role_user_ids)
        else
          []
        end
    end
end