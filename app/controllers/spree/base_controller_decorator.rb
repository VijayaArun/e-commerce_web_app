Spree::BaseController.class_eval do

  before_action :require_login
  skip_before_action :require_login, only: [:spree_login]

  private

  def logged_in?
     spree_current_user != nil
   end

  def require_login
    unless logged_in?
      redirect_to spree_login_path
    else
      if try_spree_current_user.try(:has_spree_role?, "salesman")
        redirect_to("/vendor")
      end
    end
  end

end