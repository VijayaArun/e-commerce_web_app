module Spree
  Classification.class_eval do 
    acts_as_paranoid
     belongs_to :product, class_name: "Spree::Product", inverse_of: :classifications, touch: true
  end
end