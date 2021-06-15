class VendorDetails < ActiveRecord::Migration
  def self.up
  	create_table :vendor_details do |t|
  		t.integer :user_id, null: false
  		t.integer :salesman_id, null: false
  		t.string :company_name
  		t.integer :outstanding_amount
  		t.timestamps
  	end
  	add_index :vendor_details, :user_id
  	add_index :vendor_details, :salesman_id
  end
   
  def self.down
  	drop_table :vendor_details
  end
end
