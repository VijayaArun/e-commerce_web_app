object @taxon

if params[:set] == 'nested'
  extends "spree/api/taxons/nested"
else
  attributes *taxon_attributes

  child :root => :root do
      attributes *taxon_attributes

    child :children => :taxons do
      attributes *taxon_attributes
    end
  end
end