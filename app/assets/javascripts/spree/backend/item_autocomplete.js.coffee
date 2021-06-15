# item autocompletion

variantTemplate = HandlebarsTemplates["items/autocomplete"]

formatItemResult = (item) ->
 
  variantTemplate item: item

$.fn.itemAutocomplete = (searchOptions = {}) ->
  @select2
    placeholder: Spree.translations.item_placeholder
    minimumInputLength: 1
    initSelection: (element, callback) ->
      Spree.ajax
        url: Spree.routes.taxons_api + "/" + element.val()
        success: callback
    ajax:
      url: Spree.routes.taxons_api
      datatype: "json"
      quietMillis: 500
      params: { "headers": { "X-Spree-Token": Spree.api_key } }
      data: (term, page) =>
        searchData =
          q:
            name_cont: term
          token: Spree.api_key
        _.extend(searchData, searchOptions)

      results: (data, page) ->
        window.items = data["taxons"]
        results: data["taxons"]

    formatResult: formatItemResult
    formatSelection: (variant, container, escapeMarkup) ->
      if !!variant.options_text
        Select2.util.escapeMarkup("#{variant.pretty_name} (#{variant.options_text}")
      else
        Select2.util.escapeMarkup(variant.pretty_name)
