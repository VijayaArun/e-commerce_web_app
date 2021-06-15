Spree::Address.class_eval do
  def postal_code_validate
      return if country.blank? || !require_zipcode?
      #return if !TwitterCldr::Shared::PostalCodes.territories.include?(country.iso.downcase.to_sym)

     # postal_code = TwitterCldr::Shared::PostalCodes.for_territory(country.iso)
     # errors.add(:zipcode, :invalid) if !postal_code.valid?(zipcode.to_s)
     
  end
  self.whitelisted_ransackable_attributes = %w[firstname lastname company]
  # @return [String] the full name on this Address
   def full_name
    "#{firstname} #{lastname}".strip
   end
  
 end