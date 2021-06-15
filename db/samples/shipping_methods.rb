begin
india = Spree::Zone.find_by_name!("India")
rescue ActiveRecord::RecordNotFound
  puts "Couldn't find 'North America' zone. Did you run `rake db:seed` first?"
  puts "That task will set up the countries, states and zones required for Spree."
  exit
end

tax_category = Spree::TaxCategory.find_by_name!("Default")
india = Spree::Zone.find_by_name!("India")
shipping_category = Spree::ShippingCategory.find_or_create_by!(name: 'Default')

Spree::ShippingMethod.create!([
  {
    name: "India By Road 1",
    admin_name: "by-road-1",
    available_to_all: true,
    zones: [india],
    calculator: Spree::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  },
  {
    name: "India By Road 2",
    admin_name: "by-road-2",
    available_to_all: true,
    zones: [india],
    calculator: Spree::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  }
])

{
  "India By Road 1" => [0.0, "INR"],
  "India By Road 2" => [0.0, "INR2"]
}.each do |shipping_method_name, (price, currency)|
  shipping_method = Spree::ShippingMethod.find_by_name!(shipping_method_name)
  shipping_method.calculator.preferences = {
    amount: price,
    currency: currency
  }
  shipping_method.calculator.save!
  shipping_method.save!
end
