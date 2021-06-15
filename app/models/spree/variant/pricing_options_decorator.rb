Spree::Variant::PricingOptions.class_eval do
 
  # This creates the correct pricing options for a line item, taking into account
  # its currency and tax address country, if available.
  # @see Spree::LineItem#set_pricing_attributes
  # @see Spree::LineItem#pricing_options
  # @return [Spree::Variant::PricingOptions] pricing options for pricing a line item
  #
  def self.from_line_item(line_item)
    tax_address = line_item.order.try!(:tax_address)
    curr = line_item.order.try(:currency) || line_item.currency || Spree::Config.currency
    #set the currency iso by taking its price class -> For INR2 it is IN
    new(
      currency: curr,
      country_iso: ((tax_address && tax_address.country.try!(:iso)) || (Spree::Price.where({ :currency => curr, :variant_id => line_item.variant.id })[0].country_iso))
    )
  end

end