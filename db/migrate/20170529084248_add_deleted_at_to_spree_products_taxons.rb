class AddDeletedAtToSpreeProductsTaxons < ActiveRecord::Migration
  def change
    add_column :spree_products_taxons, :deleted_at, :datetime
    add_index :spree_products_taxons, :deleted_at
  end
end
