class StockItemRemark < Remark
  has_many :spree_stock_item_stock_item_remarks, dependent: :destroy, foreign_key: :remark_id
  has_many :stock_items, class_name: 'Spree::StockItem', through: :spree_stock_item_stock_item_remarks, source: :stock_item
end
