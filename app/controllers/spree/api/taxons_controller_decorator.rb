module Spree
  module Api
    TaxonsController.class_eval do
      def siblings
        taxons = Taxon.accessible_by(current_ability, :read).where(:parent_id => taxon.parent_id)
        respond_with(taxons)
      end

      def sub_category_list
        sub_category = Taxon.all
        respond_with(sub_category)
      end

      def show
        respond_with(taxon)
      end
      private

      def taxon
        @taxon ||= Taxon.accessible_by(current_ability, :read).find(params[:id])
      end
    end
  end
end