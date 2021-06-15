class SpreeStockItemStockItemRemark < ActiveRecord::Base
  belongs_to :stock_item, class_name: Spree::StockItem, foreign_key: :spree_stock_item_id
  belongs_to :stock_item_remark, foreign_key: :remark_id

  validates :count_was, :count, presence: true, numericality: true
end
