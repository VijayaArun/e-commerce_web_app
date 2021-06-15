$(document).ready(function () {
    'use strict';

    $('[data-hook="add_product_name"]').find('.variant_autocomplete').variantAutocomplete();
    $("[data-hook='admin_orders_index_search']").find(".variant_autocomplete").variantAutocomplete();
});
