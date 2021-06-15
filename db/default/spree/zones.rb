india = Spree::Zone.find_or_create_by!(name: "India", description: "Whole of India")

%w(IN).
each do |symbol|
  india.zone_members.create!(zoneable: Spree::Country.find_by!(iso: symbol))
end