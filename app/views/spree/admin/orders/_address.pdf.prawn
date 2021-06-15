# Address Stuff

bill_address = @order.bill_address
ship_address = @order.ship_address
anonymous = @order.email =~ /@example.net$/


def address_info(address, gstnumber)
  if address.company
    info = "#{address.company},\n"
  end

  info += "#{address.address1},\n"
  info += "#{address.address2},\n" if address.address2.present?
  state = address.state ? address.state.abbr : ""
  info += "#{address.city} - #{address.zipcode}.\n"
  info += " #{state}, #{address.country.name}.\n"
  info += "#{address.first_name} #{address.last_name}" + " - " + "#{address.phone}.\n"
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
  row(0).column(1).border_widths = [0.5, 0.5, 0.5, 0]

  # Bill address information
  # row(1).column(0).borders = [:top, :right, :bottom, :left]
  # row(1).column(0).border_widths = [0.5, 0, 0.5, 0.5]

  # Ship address information
  row(1).column(1).borders = [:top, :right, :bottom, :left]
  row(1).column(1).border_widths = [0.5, 0.5, 0.5, 0]

end
