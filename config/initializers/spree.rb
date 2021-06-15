# Configure Solidus Preferences
# See http://docs.solidus.io/Spree/AppConfiguration.html for details

Spree.config do |config|
  # Without this preferences are loaded and persisted to the database. This
  # changes them to be stored in memory.
  # This will be the default in a future version.
  config.use_static_preferences!

  # Core:

  # Default currency for new sites
  config.currency = "INR"
  config.company = true

  # from address for transactional emails
  config.mails_from = "store@example.com"

  config.require_payment_to_ship = false

  config.shipping_instructions = true
  config.company = true
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false

  # When set, product caches are only invalidated when they fall below or rise
  # above the inventory_cache_threshold that is set. Default is to invalidate cache on
  # any inventory changes.
  # config.inventory_cache_threshold = 3
Money::Currency.register({
   :priority        => 100,
   :iso_code        => "INR2",
   :name            => "Due Rate",
   :symbol          => "₹",
   :alternate_symbols => ["Rs", "৳", "૱", "௹", "रु", "₨"],
   :subunit         => "Paisa",
   :subunit_to_unit => 100,
   :symbol_first => true,
   :separator       => ".",
   :delimiter       => ",",
   :thousands_separator => ",",
   :decimal_mark    =>  ".",
   :iso_numeric     => "356",
   :html_entity     =>  "&#x20b9;",
   :smallest_denomination => 50
})


  if ActiveRecord::Base.connection.table_exists? 'spree_countries'
    country = Spree::Country.find_by_name('India')

    if country.present?
      Spree::Config[:default_country_id] = country.id
      Spree::Config[:checkout_zone] = country.id
      Spree::Config[:default_country_iso] = country.id
    end
  end
  # Frontend:

  # Custom logo for the frontend
  # config.logo = "logo/solidus_logo.png"

  # Template to use when rendering layout
  # config.layout = "spree/layouts/spree_application"


  # Admin:

  # Custom logo for the admin
  config.admin_interface_logo = "logo/shree_sarees_logo.png"
  config.logo = "logo/shree_sarees_logo.png"

  # Gateway credentials can be configured statically here and referenced from
  # the admin. They can also be fully configured from the admin.
  #
  # config.static_model_preferences.add(
  #   Spree::Gateway::StripeGateway,
  #   'stripe_env_credentials',
  #   secret_key: ENV['STRIPE_SECRET_KEY'],
  #   publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  #   server: Rails.env.production? ? 'production' : 'test',
  #   test_mode: !Rails.env.production?
  # )
end

Spree::Frontend::Config.configure do |config|
  config.use_static_preferences!

  config.locale = 'en'
end

Spree::Backend::Config.configure do |config|
  config.use_static_preferences!

  config.locale = 'en'
end

Spree::Api::Config.configure do |config|
  config.use_static_preferences!

  config.requires_authentication = true
end

Spree.user_class = "Spree::LegacyUser"

Spree::PermittedAttributes.shipment_attributes << :dispatch
Spree::Api::ApiHelpers.shipment_attributes.push :dispatch

Spree::Auth::Config[:confirmable] = false
Spree::PrintInvoice::Config.set(print_invoice_logo_path: "logo/shree_sarees_logo.png")
Spree::PrintInvoice::Config.set(print_buttons: "invoice, dispatcher")

if Spree::Order.table_exists? && Spree::Order.column_names.include?(:invoice_number)
  maximum_invoice_number = Spree::Order.maximum("invoice_number") || 1000
  Spree::PrintInvoice::Config.set(print_invoice_next_number: maximum_invoice_number + 1)
end
