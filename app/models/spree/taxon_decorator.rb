Spree::Taxon.class_eval do

  acts_as_paranoid
  has_many :taxon_prices, class_name: 'Spree::TaxonPrice'
  has_many :classifications, -> { order(:position) }, dependent: :destroy, inverse_of: :taxon
  default_scope -> { order(:name) }
  scope :sub_categories, -> {where(is_item: false)}
end
