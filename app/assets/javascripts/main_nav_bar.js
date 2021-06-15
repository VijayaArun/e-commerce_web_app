$(document).ready(function() {

	$('input[type=radio][name="currency-radio"]').change(function() {
		$.ajax({
       		type: 'POST',
      		url: $(this).data('href'),
      		data: {
        		currency: $(this).val()
        	}
	    }).done(function () {
	    	window.location.reload()
	    });
    });
});