Spree::Admin::UserSessionsController.class_eval do
  
    def after_sign_in_path_for(default)
      '/admin'
    end

end
