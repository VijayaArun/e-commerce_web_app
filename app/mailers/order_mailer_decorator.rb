module Spree
  OrderMailer.class_eval do 
    include OrderHelper
    def confirm_email(order, resend = false)
      @order = find_order(order)
      @store = @order.store
      subject = build_subject(Spree.t('order_mailer.confirm_email.subject'), resend)
      if ENV['USE_INVOICE_NUMBER_FOR_ORDER_NUMBER'] != 'true'
        if Spree::PrintInvoice::Config.use_sequential_number? && !@order.invoice_number.present?
          @order.invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
          @order.invoice_date = Date.today
          @order.save!
        end
      end
      @data = items(@order)
      pdf_body = render_to_string(:template => "spree/admin/orders/invoice.pdf.prawn", :layout => false)
      attachments['invoice.pdf'] = pdf_body
      mail(to: @order.email, bcc: ENV['INVOICE_COPY_MAIL_ADDRESS'].nil? ? "" : ENV['INVOICE_COPY_MAIL_ADDRESS'], from: from_address(@store), subject: subject)
    end
  end
end