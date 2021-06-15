//= require_self
$(document).ready(function() {
    window.customerTemplate = HandlebarsTemplates['orders/customer_details/autocomplete'];

    formatCustomerResult = function(vendor) {
        return customerTemplate({
            vendor: vendor,
            company: (vendor.address && vendor.address.company) || "",
        })
    }

    if ($("#customer_search").length > 0) {
        $("#customer_search").select2({
            placeholder: Spree.translations.choose_a_vendor,
            ajax: {
                url: Spree.routes.get_vendors,
                params: { "headers": { "X-Spree-Token": Spree.api_key } },
                datatype: 'json',
                data: function(term, page) {
                    return {
                        q: {
                            m: 'or',
                            email_start: term,
                            company_start: term
                        }
                    }
                },
                results: function(data) {
                    return {
                        results: data
                    }
                }
            },
            dropdownCssClass: 'customer_search',
            formatResult: formatCustomerResult,
            formatSelection: function (customer) {
                return Select2.util.escapeMarkup(customer.email);
            }
        })

        $("#customer_search").on("select2-selecting", function(e) {
            var customer = e.choice;
            $('#order_email').val(customer.email);
            $('#user_id').val(customer.id);
            $('#guest_checkout_true').prop("checked", false);
            $('#guest_checkout_false').prop("checked", true);
            $('#guest_checkout_false').prop("disabled", false);

            var address = customer.address;
            if (address) {
                $('#order_ship_address_attributes_firstname, #order_bill_address_attributes_firstname').val(address.firstname);
                $('#order_ship_address_attributes_lastname, #order_bill_address_attributes_lastname').val(address.lastname);
                $('#order_ship_address_attributes_address1, #order_bill_address_attributes_address1').val(address.address1);
                $('#order_ship_address_attributes_address2, #order_bill_address_attributes_address2').val(address.address2);
                $('#order_ship_address_attributes_city, #order_bill_address_attributes_city').val(address.city);
                $('#order_ship_address_attributes_zipcode, #order_bill_address_attributes_zipcode').val(address.zipcode);
                $('#order_ship_address_attributes_phone, #order_bill_address_attributes_phone').val(address.phone);
                $('#order_ship_address_attributes_company, #order_bill_address_attributes_company').val(address.company);

                $('#order_ship_address_attributes_country_id, #order_bill_address_attributes_country_id').select2("val", address.country_id).promise().done(function () {
                    update_state('b', function () {
                        $('#order_ship_address_attributes_state_id, #order_bill_address_attributes_state_id').select2("val", address.state_id);
                    });
                });
            }
        });
    }

    var order_use_billing_input = $('input#order_use_billing');

    var order_use_billing = function () {
        if (!order_use_billing_input.is(':checked')) {
            $('#shipping').show();
        } else {
            $('#shipping').hide();
        }
    };

    order_use_billing_input.click(function() {
        order_use_billing();
    });

    order_use_billing();

    $('#guest_checkout_true').change(function() {
        $('#customer_search').val("");
        $('#user_id').val("");
        $('#checkout_email').val("");

        var fields = ["firstname", "lastname", "company", "address1", "address2",
            "city", "zipcode", "state_id", "country_id", "phone"]
        $.each(fields, function(i, field) {
            $('#order_bill_address_attributes' + field).val("");
            $('#order_ship_address_attributes' + field).val("");
        })
    });

    //removing disabled attr of input element for passing its value as params on server
    $("form.edit_order").on("submit", function () {
        $("#order_email").removeAttr("disabled");
        return true;
    })
});
