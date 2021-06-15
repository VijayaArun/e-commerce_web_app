class AddCountWasAndCountToSpreeStockItemStockItemRemarks < ActiveRecord::Migration
  def change
    add_column :spree_stock_item_stock_item_remarks, :count_was, :integer
    add_column :spree_stock_item_stock_item_remarks, :count, :integer
  end
end
