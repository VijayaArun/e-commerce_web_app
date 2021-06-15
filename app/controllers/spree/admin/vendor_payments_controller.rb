module Spree
  module Admin
    class VendorPaymentsController < ResourceController
        belongs_to 'spree/user', model_class: Spree.user_class
      def index
        @payments = VendorPayment.where(user_id: params[:user_id])
      end

      def new
        @payment = @user.vendor_payments.new 
      end

      def create
        @payment = @user.vendor_payments.build(permitted_resource_params)

        if @payment.save
          flash[:success] = flash_message_for(@payment, :successfully_created)
          #redirect_to admin_user_vendor_payments_path(@user)
        else
          flash[:error] = "#{Spree.t('admin.vendor_payments.unable_to_create')} #{@payment.errors.full_messages}"
          #render :new
        end
      end

      def edit
        @payment = VendorPayment.find(params[:id])
      end

      def update
        @payment = VendorPayment.find(params[:id])
        if @payment.update_attributes(permitted_resource_params)
          flash[:success] = flash_message_for(@payment, :successfully_updated)
          #redirect_to admin_user_vendor_payments_path(@user)
        else
          flash[:error] = "#{Spree.t('admin.vendor_payments.unable_to_create')} #{@payment.errors.full_messages}"
          #render :edit
        end
      end
      private

      def permitted_resource_params
        params.require(:vendor_payment).permit([:user_id, :payment, :remark])
      end
    end
  end
end