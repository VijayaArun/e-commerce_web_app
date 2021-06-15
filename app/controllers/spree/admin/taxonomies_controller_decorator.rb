module Spree
  module Admin
    TaxonomiesController.class_eval do
      def category_tree
        @taxonomy = Taxonomy.find(params[:taxonomy_id])
      end
    end
  end
end