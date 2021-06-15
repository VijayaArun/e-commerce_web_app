class RackItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', inverse_of: :rack_items
  belongs_to :rack, class_name: 'Spree::Rack', inverse_of: :rack_items
end
