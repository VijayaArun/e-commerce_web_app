object @product
cache [I18n.locale, @current_user_roles.include?('admin'), current_pricing_options, root_object]

attributes *product_attributes

node(:display_price) { |p| p.display_price.to_s }

node(:has_variants) { |p| p.has_variants? }

child :master => :master do
  extends "spree/api/variants/small"
end

child :variants => :variants do
  extends "spree/api/variants/small"
end

child :option_types => :option_types do
  attributes *option_type_attributes
end

child :product_properties => :product_properties do
  attributes *product_property_attributes
end

child :product_detail => :product_detail do
  attributes *product_details_attributes
end

child :classifications => :classifications do
  attributes :taxon_id, :position

  child(:taxon) do
    extends "spree/api/taxons/show"
  end
end
