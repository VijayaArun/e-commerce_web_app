require 'prawn/layout'
require 'prawn/icon'
@font_face = Spree::PrintInvoice::Config[:print_invoice_font_face]

font @font_face

im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:print_invoice_logo_path])
if im.present?
  image im.filename , :at => [30, 680], :scale => 0.75, position: :center
  fill_color "DAA520"
  draw_text "ISO 9001 CERTIFIED COMPANY", :at => [80, 570], :size => 9,  :style => :bold, :at => [200,570]
end

fill_color "E99323"
text Spree.t(:dispatch_form), :align => :center, :style => :bold, :size => 13
fill_color "000000"

move_down 150

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

  row(0).column(1).borders = [:top, :right, :bottom, :left]
  row(0).column(1).border_widths = [1, 1, 1, 0]

  row(1).column(1).borders = [:top, :right, :bottom, :left]
  row(1).column(1).border_widths = [0, 1, 1, 0]

end

move_down 20

data = []

  @column_widths = { 0 => 30, 1 => 350, 2 => 80, 3 => 80}
  @align = { 0 => :left, 1 => :left, 2 => :left, 3 => :right}
  data << [Spree.t(:short_number), Spree.t(:item_description), Spree.t(:rack_quantity) + '.', Spree.t(:rack)]

@serial_number = 0
if @rack_data.present?
  @rack_data.each do |item_id, item|
    product_names = item[:designs].collect{|m| m.variant.product.name}.join(", ")
    description = ""
    item[:designs].each do |manifest|
      item[:rack_units].each do |rack_unit|
        @serial_number += 1
        row = [@serial_number]
          row << item[:name] + " - " + manifest.variant.product.name
        if !item[:perfect_set]
          row << pluralize(rack_unit[:count_on_hand], 'piece')
        else
          row << pluralize(item[:set], 'set') 
        end
        row << rack_unit[:name]
        data << row
      end
    end
  end
end

extra_row_count = 0

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

move_down 8

render :partial => "spree/orders/footer.pdf.prawn"
