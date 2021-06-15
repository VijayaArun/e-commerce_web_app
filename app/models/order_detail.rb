class OrderDetail < ActiveRecord::Base
  belongs_to :spree_orders, class_name: Spree::Order
end