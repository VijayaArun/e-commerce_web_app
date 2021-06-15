Spree::BaseHelper.class_eval do
  include PricingHelper


  def display_price(product_or_variant)
    product_or_variant.price_for(current_pricing_options_for_product_or_variant(product_or_variant)).to_html
  end

end