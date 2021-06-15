Spree::UserSessionsController.class_eval do
  
   def create
    authenticate_spree_user!
  
    if spree_user_signed_in?
      respond_to do |format|
        format.html do
          flash[:success] = Spree.t(:logged_in_succesfully)
          if try_spree_current_user.try(:has_spree_role?, "salesman") 
          	redirect_to("/vendor")
          elsif try_spree_current_user.try(:has_spree_role?, "dispatcher") || try_spree_current_user.try(:has_spree_role?, "admin")
              redirect_to("/admin/orders")
          else
          	sign_out_all_scopes
            redirect_to("/login")
            #redirect_back_or_default(after_sign_in_path_for(spree_current_user))
          end
        end
        format.js { render success_json }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:error] = t('devise.failure.invalid')
          render :new
        end
        format.js do
          render json: { error: t('devise.failure.invalid') },
            status: :unprocessable_entity
        end
      end
    end
  end

end
