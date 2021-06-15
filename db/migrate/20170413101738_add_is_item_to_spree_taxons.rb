class AddIsItemToSpreeTaxons < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :is_item, :boolean, default: false
  end
end
