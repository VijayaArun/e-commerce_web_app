Spree::AppConfiguration.class_eval do
  preference :supported_currencies,   :string,  default: 'INR,INR2'

  preference :company, :boolean, default: true

  preference :alternative_shipping_phone, :boolean, default: true

  preference :alternative_billing_phone, :boolean, default: true

  preference :default_country_iso, :string, default: 'IN'

  preference :generate_api_key_for_all_roles, :boolean, default: true
end