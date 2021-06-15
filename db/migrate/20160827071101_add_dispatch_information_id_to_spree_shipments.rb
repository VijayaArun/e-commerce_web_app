class AddDispatchInformationIdToSpreeShipments < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :dispatch_information_id, :integer
  end
end
