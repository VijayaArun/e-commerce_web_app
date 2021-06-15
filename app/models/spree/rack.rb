module Spree
	class Rack < Spree::Base
		self.table_name = "racks"
		belongs_to :stock_location , class_name: 'Spree::StockLocation', touch: true
		has_many :rack_items, class_name: 'RackItem'

		validates :name, :stock_location_id, presence: true

		def total_rack_stock
			RackItem.where(:rack_id => self.id).sum(:count_on_hand)
		end
	end
end