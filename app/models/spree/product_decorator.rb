Spree::Product.class_eval do
    has_one :product_detail
    has_one :classification
    has_one :taxon, through: :classification
    self.whitelisted_ransackable_associations += %w[taxon]
    accepts_nested_attributes_for :product_detail
  	attr_accessor :net_rate, :due_rate
    after_create :add_price_after_creating_product
    has_many :classifications, dependent: :destroy, inverse_of: :product
  	def net_rate
  		prices = self.master.prices.specific_rate("INR")
  		if (prices.first)
			 prices.first.amount.to_f
		  else
			 nil
		  end
  	end

  	def due_rate
    	prices = self.master.prices.specific_rate("INR2")
    	if (prices.first)
    		prices.first.amount.to_f
    	else
    		nil
    	end
  	end

  def attributes
  	super.merge('net_rate' => self.net_rate)
  	super.merge('due_rate' => self.due_rate)
  end
  
  def add_price_after_creating_product
    taxons = self.taxons.all
    taxon_ids = []
    taxons.each do |taxon|
      taxon_ids << taxon
    end
    if Spree::TaxonPrice.find_by(taxon_id: taxon_ids).present?
      taxon_prices = Spree::TaxonPrice.where(:taxon_id => taxon_ids)
      variants = Spree::Variant.find_by(product_id: self.id)
      default_price = Spree::Price.find_by(variant_id: variants.id)
      default_price.really_destroy! if default_price.present?
      taxon_prices.each do |taxon_price|
        price = self.prices.new( variant_id: variants.id,amount: taxon_price.amount) if taxon_price.currency == "INR"
        price = self.prices.new(variant_id: variants.id ,amount: taxon_price.amount ,currency: "INR2") if taxon_price.currency == "INR2"
        price.save
      end
    end
  end
end
