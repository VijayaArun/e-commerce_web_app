module Spree
  module Api
    VariantsController.class_eval do
    def index
      @variants = scope.includes({ option_values: :option_type }, :product, :default_price, :images, { stock_items: :stock_location })
                      .ransack(params[:q]).result(distinct: true).page(params[:page]).per(params[:per_page])
      respond_with(@variants)
    end
    end
  end
end