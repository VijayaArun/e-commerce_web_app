module Spree
  module Api
    TaxonomiesController.class_eval do
      def siblings
        toxonomies = Taxonomy.accessible_by(current_ability, :read).all
        respond_with(toxonomies)
      end
    end
  end
end