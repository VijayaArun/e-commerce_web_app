class AddGstNumberToVendorDetails < ActiveRecord::Migration
  def change
    add_column :vendor_details, :gst_number, :string
  end
end
