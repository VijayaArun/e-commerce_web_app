class AddShipmentToDispatchInformations < ActiveRecord::Migration
  def change
    add_reference :dispatch_informations, :shipment, index: true
  end
end
