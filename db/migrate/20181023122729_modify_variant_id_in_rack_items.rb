class ModifyVariantIdInRackItems < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_foreign_key :rack_items, :spree_variant
        remove_index :rack_items, {:name=>'index_rack_items_on_spree_variant_id'}
	  	rename_column :rack_items, :spree_variant_id, :variant_id
	  	add_index :rack_items, :variant_id, name: 'index_rack_items_on_variant_id'
	  	add_foreign_key :rack_items, :spree_variants, column: :variant_id
      end

      dir.down do
        remove_foreign_key :rack_items, :variant
        remove_index :rack_items, {:name=>'index_rack_items_on_variant_id'}
	  	rename_column :rack_items, :variant_id, :spree_variant_id
	  	add_index :rack_items, :spree_variant_id, name: 'index_rack_items_on_spree_variant_id'
	  	add_foreign_key :rack_items, :spree_variants
      end
    end
  end
end
