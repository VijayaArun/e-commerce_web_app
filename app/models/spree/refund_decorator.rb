Spree::Refund.class_eval do
  before_save :update_vendor_details

  def update_vendor_details
    payment.order.update_vendors_outstanding_balance
  end
end