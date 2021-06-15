Spree::StockLocation.class_eval do
  has_many :racks, class_name: 'Spree::Rack'
end
