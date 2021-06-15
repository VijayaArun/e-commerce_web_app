object @product
cache [I18n.locale, @current_user_roles.include?('admin'), current_pricing_options, root_object]

attributes :id,:name,:description,:taxon_ids,:total_on_hand,:net_rate,:due_rate

child :master => :master do
  extends "spree/api/variants/extra_small"
end

child :product_detail => :product_detail do
  attributes *product_details_attributes
end
