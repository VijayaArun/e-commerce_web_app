module PricingHelper

  def current_pricing_options_for_product_or_variant(product_or_variant)
    # ensure session currency is supported
    #
    if session.key?(:currency) && supported_currencies.map(&:iso_code).include?(session[:currency])
	    Spree::Config.pricing_options_class.new(
            currency: session[:currency],
            country_iso: Spree::Price.where({ :currency => session[:currency], :variant_id => product_or_variant.is_a?(Spree::Variant) ? product_or_variant.id : product_or_variant.master.id })[0].country_iso
        )
    else
      current_pricing_options
    end
  end
end
