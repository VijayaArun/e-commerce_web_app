object @shipment
attributes *shipment_attributes
node(:order_id) { |shipment| shipment.order.number }
node(:stock_location_name) { |shipment| shipment.stock_location.name }
node(:dispatch) { |shipment| shipment.dispatch_information ? shipment.dispatch_information.number : "" }

child :shipping_rates => :shipping_rates do
  extends "spree/api/shipping_rates/show"
end

child :selected_shipping_rate => :selected_shipping_rate do
  extends "spree/api/shipping_rates/show"
end

child :shipping_methods => :shipping_methods do
  attributes :id, :name
  child :zones => :zones do
    attributes :id, :name, :description
  end

  child :shipping_categories => :shipping_categories do
    attributes :id, :name
  end
end

#TODO: Need to modify code according to new manifest
#child :manifest => :manifest do
#  child :variant => :variant do
#    extends "spree/api/variants/small"
#  end
#  node(:quantity) { |m| m.quantity }
#  node(:states) { |m| m.states }
#end