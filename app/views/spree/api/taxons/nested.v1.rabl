attributes *taxon_attributes

child @object => :root do
  attributes *taxon_attributes

  child :children => :taxons do
    attributes *taxon_attributes
  end
end