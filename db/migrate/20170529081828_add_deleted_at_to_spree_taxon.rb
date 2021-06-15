class AddDeletedAtToSpreeTaxon < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :deleted_at, :datetime
    add_index :spree_taxons, :deleted_at
  end
end
