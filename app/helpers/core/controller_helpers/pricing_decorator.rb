Spree::Core::ControllerHelpers::Pricing.class_eval do

  def current_pricing_options
    # ensure session currency is supported
    #
    if session.key?(:currency) && supported_currencies.map(&:iso_code).include?(session[:currency])
      searched_currency = nil
      Money::Currency.each do |money|
        if session[:currency] == money.iso_code
          searched_currency = money
          break
        end
      end
      unless searched_currency.nil?
        Spree::Config.pricing_options_class.new(
            currency: searched_currency.iso_code,
            country_iso: Spree::Country.where({ :numcode => searched_currency.iso_numeric })[0].iso
        )
      else
        Spree::Config.pricing_options_class.new(
            currency: session[:currency],
            country_iso: Spree::Price.where({ :currency => session[:currency] })[0].country_iso
        )
      end
    else
	    Spree::Config.pricing_options_class.new(
            currency: current_store.try!(:default_currency).presence || Spree::Config[:currency]
        )
    end
  end
end
