Spree::Variant.class_eval do
  has_many :rack_items, dependent: :destroy, inverse_of: :variant
end
