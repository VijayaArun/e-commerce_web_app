Spree::Sample.load_sample("taxonomies")
Spree::Sample.load_sample("products")

cotton = Spree::Taxonomy.find_by_name!("Cotton")
synthetic = Spree::Taxonomy.find_by_name!("Synthetic")

taxons = [
  {
    name: "Cotton border printed",
    taxonomy: cotton,
    parent: "Cotton",
    position: 1
  },
  {
    name: "Cotton fresh mix(SST)",
    taxonomy: cotton,
    parent: "Cotton",
    position: 2
  },
  {
    name: "Cotton mix second",
    taxonomy: cotton,
    parent: "Cotton",
    position: 3
  },
  {
    name: "Cotton plain printed",
    taxonomy: cotton,
    parent: "Cotton",
    position: 4
  },
  {
    name: "Cotton print attach border / applic",
    taxonomy: cotton,
    parent: "Cotton",
    position: 5
  },
  {
    name: "Cotton work",
    taxonomy: cotton,
    parent: "Cotton",
    position: 6
  },
  {
    name: "Soft cotton",
    taxonomy: cotton,
    parent: "Cotton",
    position: 7
  },
  {
    name: "Fancy cotton border printed",
    taxonomy: synthetic,
    parent: "Synthetic",
    position: 1
  },
  {
    name: "Fancy cotton plain printed",
    taxonomy: synthetic,
    parent: "Synthetic",
    position: 2
  },
  {
    name: "Fancy cotton print with attach border",
    taxonomy: synthetic,
    parent: "Synthetic",
    position: 3
  },
  {
    name: "Fancy cotton print with work",
    taxonomy: synthetic,
    parent: "Synthetic",
    position: 4
  },
  {
    name: "Fancy cotton work",
    taxonomy: synthetic,
    parent: "Synthetic",
    position: 5
  }
]

taxons.each do |taxon_attrs|
  if taxon_attrs[:parent]
    taxon_attrs[:parent] = Spree::Taxon.find_by_name!(taxon_attrs[:parent])
    Spree::Taxon.create!(taxon_attrs)
  end
end
