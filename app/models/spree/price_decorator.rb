Spree::Price.class_eval do

  scope :specific_rate , -> (specific_rate){ where(:currency => specific_rate ) if specific_rate.present? }

end
