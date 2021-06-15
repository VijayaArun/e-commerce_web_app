class Spree::Api::TimestampController < Spree::Api::BaseController

  def index
    @data = [{
      product_updated_at: product.first.updated_at,
      order_updated_at: order.first.updated_at,
      stock_updated_at: stock_item.first.updated_at,
      price_updated_at: price.first.updated_at,
    }]
  end

  def product
    @product_updated_at = Spree::Product.order("updated_at desc").limit(1)
  end

  def order
    @order_updated_at = Spree::Order.order("updated_at desc").limit(1)
  end

  def stock_item
    @stock_item_updated_at = Spree::StockItem.order("updated_at desc").limit(1)
  end

  def price
    @price_updated_at = Spree::Price.order("updated_at desc").limit(1)
  end

end
