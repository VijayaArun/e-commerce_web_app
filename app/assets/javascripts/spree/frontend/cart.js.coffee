Spree.ready ($) ->
  if ($ 'form#update-cart').is('*')
    ($ 'form#update-cart a.delete').show().one 'click', ->
      ($ this).parents('.line-item').first().find('input.line_item_quantity').val 0
      ($ this).parents('form').first().submit()
      false

  ($ 'form#update-cart').submit ->
    ($ 'form#update-cart #update-button').attr('disabled', true)

Spree.fetch_cart = (cartLinkUrl) ->
  Spree.ajax
    url: cartLinkUrl || Spree.pathFor("cart_link"),
    success: (data) ->
      $('#link-to-cart').html data
      if ($ 'a.cart-info').hasClass('full')
        ($ 'input[type=radio][name="currency-radio"]').attr("disabled", true);
