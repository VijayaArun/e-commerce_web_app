Spree::OrdersController.class_eval do
  def show
    @order = Spree::Order.find_by_number!(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        if @order.completed?
          template = params[:template] || "invoice"
          if (template == "invoice") && Spree::PrintInvoice::Config.use_sequential_number? && !@order.invoice_number.present?
            @order.invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
            @order.invoice_date = Date.today
            @order.save!
          end
          render :layout => false , :template => "spree/orders/#{template}.pdf.prawn"
        else
          redirect_to '/', error: 'Order needs to be completed!'
        end
      end
    end
  end

  # def download
  #   require 'open-uri'
  #   open('image.png', 'wb') do |file|
  #     file << open('http://example.com/image.png').read
  #   end
  # end
end