taxonomies = [
  { name: "Cotton" },
  { name: "Synthetic" }
]

taxonomies.each do |taxonomy_attrs|
  Spree::Taxonomy.create!(taxonomy_attrs)
end
