module Spree
  class FrontendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

  

    SELECTION_TAB         ||= [:select_retailer]
    ADD_RETAILER			  ||= [:add_retailer]
    REPORTS				  ||= [:check_reports]

end
end