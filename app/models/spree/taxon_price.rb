module Spree
  class TaxonPrice < ActiveRecord::Base
    belongs_to :taxon , class_name: 'Spree::Taxon', touch: true
    after_update :update_product_prices

    extend DisplayMoney
    money_methods :amount, :price
    alias_method :money, :display_amount

    # An alias for #amount
    def price
      amount
    end
    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end
     # @return [Boolean] true if this variant has been deleted
    def deleted?
      !!deleted_at
    end

    def update_product_prices
      taxon_id = self.taxon_id
      product_ids = Spree::Classification.where(taxon_id: taxon_id).pluck(:product_id)
      variant_ids = Spree::Variant.where(product_id: product_ids).pluck(:id)
      updated_amounts = Spree::TaxonPrice.where(taxon_id: taxon_id)
      variant_ids.each do |variant_id|
        variant_prices = Spree::Price.where(variant_id: variant_id)
        updated_amounts.each do |updated_amount|
          variant_prices.where(currency: updated_amount.currency, is_default: 1).update_all(amount: updated_amount.amount, updated_at: DateTime.now)          
        end
      end      
    end
  end
end