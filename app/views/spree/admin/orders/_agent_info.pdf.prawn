move_down 290
font @font_face,  :size => 9,  :style => :bold
  text "Please supply us under mentioned goods on our accounts & risk on below mentioned destination"
  if @order.order_detail && @order.order_detail.transport_info.present?
    text "Goods to be booked to station #{@order.order_detail.transport_info}"
  else
    text "Goods to be booked to station _________________"
  end