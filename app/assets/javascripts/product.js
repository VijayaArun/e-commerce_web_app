$(function(){
		
	function changeQuantity() {
		var multiplier = window.product && window.product.noOfProducts ?  window.product.noOfProducts : 1;
		$('.add-to-cart #quantity').val(parseInt($('.add-to-cart #custom-quantity').val()) * multiplier);
	}

	$('.add-to-cart #custom-quantity').off('.quantity').on('change.quantity', changeQuantity);
	changeQuantity();

});