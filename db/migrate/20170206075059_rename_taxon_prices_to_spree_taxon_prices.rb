class RenameTaxonPricesToSpreeTaxonPrices < ActiveRecord::Migration
  def change
    rename_table :taxon_prices, :spree_taxon_prices
  end
end
