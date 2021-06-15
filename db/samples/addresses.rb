india = Spree::Country.find_by_name!("India")
maharashtra = Spree::State.find_by_name!("Maharashtra")

# Billing address
Spree::Address.create!(
  firstname: FFaker::Name.first_name,
  lastname: FFaker::Name.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: maharashtra,
  zipcode: 400069,
  country: india,
  phone: FFaker::PhoneNumber.phone_number)

# Shipping address
Spree::Address.create!(
  firstname: FFaker::Name.first_name,
  lastname: FFaker::Name.last_name,
  address1: FFaker::Address.street_address,
  address2: FFaker::Address.secondary_address,
  city: FFaker::Address.city,
  state: maharashtra,
  zipcode: 421202,
  country: india,
  phone: FFaker::PhoneNumber.phone_number)