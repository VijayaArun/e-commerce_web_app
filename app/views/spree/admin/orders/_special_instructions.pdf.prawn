move_down 270
special_instructions = "Special instructions: "
if @order.special_instructions.present?
  special_instructions += "#{@order.special_instructions}"
else
  special_instructions += "None"
end
font @font_face,  :size => 9,  :style => :bold
  text special_instructions