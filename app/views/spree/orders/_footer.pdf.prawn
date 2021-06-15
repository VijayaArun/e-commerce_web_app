bounding_box [bounds.left, bounds.bottom + 25], :width  => bounds.width do
  font @font_face,  :size => 9,  :style => :bold
  text "Note: This is computer generated order form, no need for signature. Payment to be done within " + (@order.currency == "INR" ? "30" : "60") + " days net. No less discount.", :align => :left
end

