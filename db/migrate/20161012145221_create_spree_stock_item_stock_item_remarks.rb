class CreateSpreeStockItemStockItemRemarks < ActiveRecord::Migration
  def up
    create_table :spree_stock_item_stock_item_remarks do |t|
      t.references :spree_stock_item, foreign_key: true
      t.references :remark, foreign_key: true

      t.timestamps null: false
    end
    add_index :spree_stock_item_stock_item_remarks, [:spree_stock_item_id, :remark_id], name: :by_foreign_key_combination
  end

  def down
    drop_table :spree_stock_item_stock_item_remarks
  end
end
