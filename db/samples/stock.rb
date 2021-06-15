country =  Spree::Country.find_by(name: 'India')
locations = Spree::StockLocation.create!([
	{
		name: 'Mumbai', 
		address1: 'Example Street', 
		city: 'Mumbai', 
		zipcode: '12345', 
		country: country, 
		state: country.states.first
	},
	{
		name: 'Ahmedabad', 
		address1: 'Example Street', 
		city: 'Ahmedabad', 
		zipcode: '12398', 
		country: country, 
		state: country.states.first
	},
	{
		name: 'Bhiwandi', 
		address1: 'Example Street', 
		city: 'Bhiwandi', 
		zipcode: '12389', 
		country: country, 
		state: country.states.first
	}
])

locations.each do |l|
	l.active = true
	l.save!
end

Spree::StockLocation.find_by(name: 'default').destroy
