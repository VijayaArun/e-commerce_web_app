module Spree
  class VendorPayment < Spree::Base
    self.table_name = 'vendor_payments'
    belongs_to :User, class_name: 'Spree::User'
    after_save :update_outstanding_amount

    def update_outstanding_amount
      user_id = self.user_id
      user = Spree::User.where(id: user_id).first
      user.store_outstanding_amount!
    end
 end
end