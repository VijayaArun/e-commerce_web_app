class ChangeColumnTypeOfOutstandingAmountFromVendorDetail < ActiveRecord::Migration
  def up
    change_column :vendor_details, :outstanding_amount, :float, default: 0
  end
  def down
    change_column :vendor_details, :outstanding_amount, :integer
  end
end
