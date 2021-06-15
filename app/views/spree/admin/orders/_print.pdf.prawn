require 'prawn/layout'
require 'prawn/icon'
@font_face = Spree::PrintInvoice::Config[:print_invoice_font_face]

font @font_face

im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:print_invoice_logo_path])
if im.present?
  image im.filename , :at => [30, 680], :scale => 0.75
  fill_color "DAA520"
  draw_text "ISO 9001 CERTIFIED COMPANY", :at => [80, 570], :size => 9,  :style => :bold
end

fill_color "E99323"
if @hide_prices
  text Spree.t(:packaging_slip), :align => :right, :style => :bold, :size => 18
else
  text Spree.t(:order_form), :align => :center, :style => :bold, :size => 13
end
fill_color "000000"


font @font_face,  :size => 9,  :style => :bold
  draw_text "Mumbai(H.O):", :at => [300, 690]
  pdf.bounding_box([300, 686], :width => 400) do
    pdf.icon('fa-circle', size: 5)
  end
  draw_text "   26 Old Hanuman, 1st Cross Lane, Kalbadevi,", :at => [300, 680]
  draw_text "Mumbai 400002", :at => [307, 670]
  draw_text "GST No. 27ABLFS0458C1Z7", :at => [307, 660]
  pdf.bounding_box([307, 657], :width => 400) do
    pdf.icon('fa-phone', size: 9)
  end
  draw_text "     :022-2242-38-00/4924-04-50", :at => [307, 650]
  pdf.bounding_box([307, 648], :width => 400) do
    pdf.icon('fa-envelope', size: 9)
  end
  draw_text "     :shreesarees@gmail.com", :at => [307, 640]

  
  draw_text "Ahmedabad:", :at => [300, 630]
  pdf.bounding_box([300, 625], :width => 400) do
    pdf.icon('fa-circle', size: 5)
  end
  draw_text "   Sales: 151, New Cloth Market, Opposite Raipur Gate,", :at => [300, 620]
  draw_text "Ahmedabad 380002", :at => [307, 610]
  pdf.bounding_box([307, 607], :width => 400) do
    pdf.icon('fa-phone', size: 9)
  end
  draw_text "     :029-2216-00-60", :at => [307, 600]
  pdf.bounding_box([300, 596], :width => 400) do
    pdf.icon('fa-circle', size: 5)
  end
  draw_text "   Depot :Shree Bunglows, Hira Baug Crossing,", :at => [300, 590]
  draw_text "Ambawadi, Ahmedabad 380006", :at => [307, 580]
  draw_text "GST No. 24ABLFS0458C1ZD", :at => [307, 570]
  pdf.bounding_box([307, 567], :width => 400) do
    pdf.icon('fa-phone', size: 9)
  end
  draw_text "     :079-2642-42-70/2642-42-80", :at => [307, 560]


#table([ [{:image => im.filename}]])
# if Spree::PrintInvoice::Config.use_sequential_number? && @order.invoice_number.present? && !@hide_prices

#   font @font_face,  :size => 9,  :style => :bold
#   text "#{Spree.t(:invoice_number)} #{@order.invoice_number}", :align => :right

#   move_down 2
#   font @font_face, :size => 9
#   text "#{Spree.t(:invoice_date)} #{I18n.l @order.invoice_date}", :align => :right

# else

#   move_down 2
#   font @font_face,  :size => 9
#   text "#{Spree.t(:order_number, :number => @order.number)}", :align => :right

#   move_down 2
#   font @font_face, :size => 9
#   text "#{I18n.l @order.completed_at.to_date}", :align => :right

# end


### Start of address chunk
#render :partial => "spree/admin/orders/address.pdf.prawn"

bill_address = @order.bill_address
ship_address = @order.ship_address
anonymous = @order.email =~ /@example.net$/


def address_info(address, gstnumber)
  if address.nil?
    info = "No address provided\n"
  else
    if address.company
    info = "#{address.company},\n"
    end

    info += "#{address.address1},\n"
    info += "#{address.address2},\n" if address.address2.present?
    state = address.state ? address.state.abbr : ""
    info += "#{address.city} - #{address.zipcode}.\n"
    info += " #{state}, #{address.country.name}.\n"
    info += "#{address.first_name} #{address.last_name}" + " - " + "#{address.phone}.\n"
  end
  info += "GST - #{gstnumber}\n" unless gstnumber.nil?
  info.strip
end

invoicenumber = nil
if ENV['USE_INVOICE_NUMBER_FOR_ORDER_NUMBER'] != 'true' && Spree::PrintInvoice::Config.use_sequential_number? && @order.invoice_number.present?
  invoicenumber = "Invoice Number: #{@order.invoice_number}"
else
  invoicenumber = "Order Number: #{@order.number}"
end

usergst = nil
unless @order.user.vendor_detail.gst_number.nil?
  usergst = @order.user.vendor_detail.gst_number
else
  usergst = "Not updated"
end

data = [
  [Spree.t(:address), Spree.t(:order_info)],
  if @order.order_detail && @order.order_detail.agent_info.present?
    [ address_info(ship_address, usergst) + "\n\n", invoicenumber + "\n\n" + "Order Date: #{@order.completed_at.to_date.to_s}" + "\n\n" +  "Broker Name: #{@order.order_detail.agent_info}" ]

  else
    [ address_info(ship_address, usergst) + "\n\n", invoicenumber + "\n\n" + "Order Date: #{@order.completed_at.to_date.to_s}" + "\n\n" ]

  end
]

move_down 10
table(data, :width => 540) do
  row(0).font_style = :bold

  # Billing address header
  # row(0).column(0).borders = [:top, :right, :bottom, :left]
  # row(0).column(0).border_widths = [0.5, 0, 0.5, 0.5]

  # Shipping address header
  row(0).column(1).borders = [:top, :right, :bottom, :left]
  row(0).column(1).border_widths = [1, 1, 1, 0]

  # Bill address information
  # row(1).column(0).borders = [:top, :right, :bottom, :left]
  # row(1).column(0).border_widths = [0.5, 0, 0.5, 0.5]

  # Ship address information
  row(1).column(1).borders = [:top, :right, :bottom, :left]
  row(1).column(1).border_widths = [0, 1, 1, 0]

end

### End of address chunk

### Start of transport chunk

#render :partial => "spree/admin/orders/agent_info.pdf.prawn"

move_down 20
font @font_face,  :size => 9,  :style => :bold
  text "Please supply us under mentioned goods on our accounts & risk on below mentioned destination"
  if @order.order_detail && @order.order_detail.transport_info.present?
    text "Goods to be booked to station #{@order.order_detail.transport_info}"
  else
    text "Goods to be booked to station _________________"
  end

### End of transport chunk

### Start of products chunk

move_down 20

#render :partial => "spree/admin/orders/line_items_box.pdf.prawn"

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

#move_down(310)
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

### End of products chunk

### Start of special instructions chunk

#render :partial => "spree/admin/orders/special_instructions.pdf.prawn"

move_down(20)
special_instructions = "Special instructions: "
if @order.special_instructions.present?
  special_instructions += "#{@order.special_instructions}"
else
  special_instructions += "None"
end
font @font_face,  :size => 9,  :style => :bold
  text special_instructions

move_down 8

### End of special instructions chunk

# Footer
render :partial => "spree/orders/footer.pdf.prawn"
