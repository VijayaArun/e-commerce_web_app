Spree::Api::StockItemsController.class_eval do
  include Spree::AuthenticationHelpers

  def update_multiple
    params[:stock_items] = JSON.parse(params[:stock_items])
    params[:variant] = JSON.parse(params[:variant])
    @stock_items = Spree::StockItem.accessible_by(current_ability, :update).where(id: params[:stock_items].keys)
    @updated_items = []
    Spree::StockItem.transaction do
      @stock_item_remark = StockItemRemark.create(content: params[:remark], action: 'Bulk Upload')
      @stock_items.each do |stock_item|

        updates = nested_stock_item_params[:stock_items][stock_item.id.to_s]
        # creating intermediate record to associate stock item with stock item remark
        stock_item_stock_remark = @stock_item_remark.spree_stock_item_stock_item_remarks.create(
          spree_stock_item_id: stock_item.id,
          count_was: stock_item.count_on_hand,
          count: updates[:count_on_hand].to_i
        )

        # calculations for adjustment of count on hand
        if updates.has_key?(:count_on_hand)
          adjustment = updates[:count_on_hand].to_i
          updates.delete(:count_on_hand)
          adjustment -= stock_item.count_on_hand
        else
          adjustment = 0
        end

      
        unless updates.has_key?(:backorderable)
          updates[:backorderable] = 0
        else
          updates[:backorderable] = 1
        end

        if stock_item.update_attributes(updates)
          adjust_stock_item_count_on_hand_for_multiple(adjustment, stock_item)
          @updated_items << stock_item
        else
          invalid_resource!(stock_item)
          return true
        end
      
      end
    end
    if @stock_items.count == @updated_items.count
      head :ok
    else
      head 422
    end

    begin
      @variants = Spree::Variant.accessible_by(current_ability, :update).where(id: params[:variant].keys)
      @variants.each do |variant|
        variant_updates = params[:variant][variant.id.to_s]
        if variant_updates.has_key?(:name)
          product = Spree::Product.find(variant.product_id)
          product.name = variant_updates[:name]
          product.product_detail.set_size = variant_updates[:setsize]
          product.save
        end
      end

      @variants.each do |variant|
        variant_id = variant.id
        attachment =  params["image" + variant_id.to_s]
        variant_img = Spree::Image.where(viewable_id: variant_id).first
        if attachment.present?
          if variant_img.present?
            delete_image = Spree::Image.destroy(variant_img.id)
          end
          images = Spree::Image.new(viewable_id: variant_id, viewable_type: "Spree::Variant")
          images.attachment = attachment
          images.save
        end
      end
    rescue => e
      head 422
    end
  end

  private

  def nested_stock_item_params
    params.permit(stock_items: [:backorderable, :count_on_hand, :force])
  end

  def adjust_stock_item_count_on_hand_for_multiple(count_on_hand_adjustment, stock_item)
    if (stock_item.count_on_hand + count_on_hand_adjustment < 0 && count_on_hand_adjustment < 0)
      raise StockLocation::InvalidMovementError.new(Spree.t(:stock_not_below_zero))
    end
    stock_movement = stock_item.stock_location.move(stock_item.variant, count_on_hand_adjustment, current_api_user)
    stock_item = stock_movement.stock_item
  end

end