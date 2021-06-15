module Spree
module OrderHelper
  def items(order)
      # Grouping by the ID means that we don't have to call out to the association accessor
      # This makes the grouping by faster because it results in less SQL cache hits.
     item_details = {}
      manifest_items = order.inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
        manifest_item = variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
          variant = units.first.variant
          taxon = variant.product.taxons.with_deleted.first
          price = taxon.taxon_prices.where(currency: units.first.order.currency).first.amount.to_f
          if (item_details[taxon.id].nil?)          
            item_details[taxon.id] = {
              name: taxon.name,
              price: price,
              quantity: units.length,
              total_price: units.length * price
            }
          else
            item_detail = item_details[taxon.id]
            item_detail[:quantity] += units.length
            item_detail[:total_price] += units.length * price
          end
          states = {}
          units.group_by(&:state).each { |state, iu| states[state] = iu.count }

          line_item = units.first.line_item
          ManifestItem.new(line_item, variant, units.length, states, taxon.id)
        end
      end.flatten
      manifest_items.each do |manifest_item|
        item_detail = item_details[manifest_item.item_id]
        product = manifest_item.variant.product
        set_size = product.product_detail.set_size.to_i
        if (item_detail[:designs].nil?)
          item_detail[:designs] = [manifest_item]
          item_detail[:perfect_set] = true
          item_detail[:set] = 0
        else
          item_detail[:designs] << manifest_item
        end
        item_detail[:set] += (manifest_item.quantity / set_size.to_i) if item_detail[:perfect_set]
        item_detail[:perfect_set] = item_detail[:perfect_set] && (manifest_item.quantity % set_size == 0)
        if !item_detail[:perfect_set]
          item_detail[:set] = -1
        end
      end
      item_details
    end
end
end