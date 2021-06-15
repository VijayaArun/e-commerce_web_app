class AddDeletedAtToVendorDetails < ActiveRecord::Migration
  def change
    add_column :vendor_details, :deleted_at, :datetime
    add_index :vendor_details, :deleted_at
  end
end
