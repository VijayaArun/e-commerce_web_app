Spree.routes.taxons_api = Spree.pathFor('api/taxons');
Spree.routes.get_vendors =  Spree.pathFor('api/users/vendor');
Handlebars.registerHelper("admin_url", function() {
  return Spree.pathFor("admin");
});