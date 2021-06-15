class RemoveCompanyNameFromVendorDetails < ActiveRecord::Migration
  def self.up
    remove_column :vendor_details, :company_name
  end

  def self.down
 	 remove_column :vendor_details, :company_name, :string
  end
end
