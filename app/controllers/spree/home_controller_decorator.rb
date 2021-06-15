Spree::HomeController.class_eval do

	def index
      #Add default currency if three is no currency set in session to fix initial load of home page incase of admin login 
      session[:currency] = session[:currency] ? session[:currency] : 'INR'	
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end
end
