Spree::Api::UsersController.class_eval do
  def getvendor
    vendors = []
    @returnArr = []

    users = Spree::User.accessible_by(current_ability, :read).ransack(params[:q]).result
    users.each do |user|
      if user.vendor?
        vendors.push(user)
      end
    end

    vendors.each do |vendor|
      obj = {
          "id" => vendor.id,
          "email" => vendor.email
      }
      vendor.addresses.each do |address|
        if obj["address"].nil?
          obj["address"]= address
        elsif obj["address"].updated_at < address.updated_at
          obj["address"]= address
        end
      end
      @returnArr.push(obj)
    end

    respond_with(@returnArr)
  end
end