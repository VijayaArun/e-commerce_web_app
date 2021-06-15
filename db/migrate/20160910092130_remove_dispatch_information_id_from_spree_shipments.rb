class RemoveDispatchInformationIdFromSpreeShipments < ActiveRecord::Migration
  def change
  	remove_column :spree_shipments, :dispatch_information_id, :integer
  end
end
