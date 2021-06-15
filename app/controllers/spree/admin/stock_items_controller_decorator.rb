Spree::Admin::StockItemsController.class_eval do
  self.variant_display_attributes = [
      { translation_key: :sku, attr_name: :sku },
      { translation_key: :name, attr_name: :name, editable: true }
  ]
  def load_stock_management_data
    @stock_locations = Spree::StockLocation.accessible_by(current_ability, :read)
    @stock_item_stock_locations = params[:stock_location_id].present? ? @stock_locations.where(id: params[:stock_location_id]) : @stock_locations
    @variant_display_attributes = self.class.variant_display_attributes
    @variants = Spree::Config.variant_search_class.new(params[:variant_search_term], scope: variant_scope).results
    @variants = @variants.includes(:images, stock_items: :stock_location, product: :variant_images)
    @variants = @variants.includes(option_values: :option_type)
    if !params[:item_id].nil?
      @variants = @variants.order(id: :asc)
    else
      @variants = @variants.order(id: :desc).page(params[:page]).per(params[:per_page] || Spree::Config[:orders_per_page])
    end
  end

  def variant_scope
    scope = Spree::Variant.accessible_by(current_ability, :read)
    if @product
      scope = scope.where(product: @product)
    elsif !params[:item_id].nil?
      scope = scope.where(product: Spree::Taxon.find(params[:item_id]).products)
    end
    scope
  end
end