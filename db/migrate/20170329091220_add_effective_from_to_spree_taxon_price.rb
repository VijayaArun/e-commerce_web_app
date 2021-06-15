class AddEffectiveFromToSpreeTaxonPrice < ActiveRecord::Migration
  def change
    add_column :spree_taxon_prices, :effective_from, :datetime, null: false
  end
end
