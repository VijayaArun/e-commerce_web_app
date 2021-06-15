Spree::StockItem.class_eval do
    self.whitelisted_ransackable_attributes = ['count_on_hand', 'stock_location_id', 'variant_id']
    #after_save :conditional_variant_touch, if: :changed?
    def conditional_variant_touch
      variant if inventory_cache_threshold.nil? || should_touch_variant?
    end
end