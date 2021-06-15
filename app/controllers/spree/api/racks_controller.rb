class Spree::Api::RacksController < Spree::Api::BaseController
	def index
		racks = Spree::Rack.all.to_json(:include => :stock_location)
		respond_with(racks)
	end
end