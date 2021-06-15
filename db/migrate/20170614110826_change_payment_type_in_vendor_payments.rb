class ChangePaymentTypeInVendorPayments < ActiveRecord::Migration
  def change
    change_table :vendor_payments do |t|
     t.change :payment, :decimal, :precision => 10, :scale => 2
    end
  end
end
