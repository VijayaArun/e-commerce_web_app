module ApplicationHelper
  def get_display_quantity(id,quantity)
  	noOfProductInASet = get_set_size(Spree::Product.find(id))
  	quantityValue = noOfProductInASet && (((quantity.to_i) % (noOfProductInASet.to_i)) == 0)
    value = quantityValue ? (((quantity.to_i) / (noOfProductInASet.to_i)).to_s + ' X ' + noOfProductInASet.to_s) : quantity
  	return value
  end

  def get_set_size(product)
  	return product.product_detail && product.product_detail.set_size ? product.product_detail.set_size : 1
  end
end
