Spree::Api::ProductsController.class_eval do
  include Spree::CurrencyHelpers

  def stock_quantity
    products = Spree::Product.all
    @data = products.map do |product|
      {
        product_id: product.master.id,
        count_on_hand: product.total_on_hand,
        backorderable: product.master.is_backorderable?
      }
    end
  end

  def product_prices
    products = Spree::Product.all
    @data = products.map do |product|
    {
      product_id: product.master.id,
      net_rate: product.net_rate,
      due_rate: product.due_rate
    }
    end
  end
end