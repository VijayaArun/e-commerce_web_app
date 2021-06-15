data = []

if @hide_prices
  @column_widths = { 0 => 30, 1 => 375, 2 => 75, 3 => 75 }
  @align = { 0 => :left, 1 => :left, 2 => :right, 3 => :right }
  data << [Spree.t(:short_number), Spree.t(:item_description), Spree.t(:qty) + '.']
else
  @column_widths = { 0 => 30, 1 => 310, 2 => 75, 3 => 50, 4 => 75 }
  @align = { 0 => :left, 1 => :left, 2 => :left, 3 => :right, 4 => :right}
  data << [Spree.t(:short_number), Spree.t(:item_description), Spree.t(:qty) + '.', Spree.t(:rate), Spree.t(:total)]
end

@serial_number = 0
if @data.present?
  @data.each do |item_id, item|
    @serial_number += 1
    product_names = item[:designs].collect{|m| m.variant.product.name}.join(", ")
    row = [@serial_number]
    description = ""
    item[:designs].each do |manifest|
      if item[:designs].count < 2
        description = item[:name] + " - " + manifest.variant.product.name
      else
        description = item[:name] + " - " + product_names
      end
    end
    row << description
    if !item[:perfect_set]
      row << pluralize(item[:quantity], 'piece')
    else
      row << pluralize(item[:set], 'set')
    end
    row << item[:price]
    row << item[:total_price]
    data << row
  end
end

extra_row_count = 0

unless @hide_prices
  extra_row_count += 1
  data << [""] * 5
  data << [nil, nil, nil, Spree.t(:subtotal), @order.item_total.to_s]

  @order.all_adjustments.eligible.each do |adjustment|
    extra_row_count += 1
    data << [nil, nil, nil, adjustment.label, adjustment.display_amount.to_s]
  end

  data << [nil, nil, nil, Spree.t(:total), @order.total.to_s]
end

move_down(310)
table(data, :width => @column_widths.values.compact.sum, :column_widths => @column_widths) do
  cells.border_width = 0.5

  row(0).borders = [:bottom]
  row(0).font_style = :bold

  last_column = data[0].length - 1
  row(0).columns(0..last_column).borders = [:top, :right, :bottom, :left]

  row(0).column(last_column - 1).border_widths = [0.5, 0.5, 0.5, 0.5]

  if extra_row_count > 0
    extra_rows = row((-2-extra_row_count)..-2)
    extra_rows.columns(0..5).borders = []
    extra_rows.column(4).font_style = :bold

    row(-1).columns(0..5).borders = []
    row(-1).column(4).font_style = :bold
  end
end
