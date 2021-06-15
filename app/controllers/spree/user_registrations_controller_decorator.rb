Spree::UserRegistrationsController.class_eval do

	private

		def spree_user_params
			params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes | [:created_by_id, :email, :name])
		end

end