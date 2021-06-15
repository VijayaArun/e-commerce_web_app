class CreateTableVendorPayments < ActiveRecord::Migration
  def change
    create_table :vendor_payments do |t|
      t.integer :user_id
      t.integer :payment
      t.string :remark
      t.timestamps null: false
    end
  end
end
