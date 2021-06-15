Spree::Order.class_eval do
  self.whitelisted_ransackable_associations = %w[shipments user promotions bill_address ship_address line_items taxons]
  has_one :order_detail
  has_many :taxons, -> { with_deleted }, through: :products
  ORDER_NUMBER_LENGTH  ||= 9
  ORDER_NUMBER_LETTERS ||= false
  ORDER_NUMBER_PREFIX ||= 'R'

  checkout_flow do
    go_to_state :address
    go_to_state :delivery
    go_to_state :payment, if: ->(order) { order.payment_required? }
    go_to_state :confirm
  end

delegate :firstname, :lastname, :company, to: :bill_address, prefix: true, allow_nil: true
alias_method :billing_company, :bill_address_company

 def tax_address
 end

 def create_tax_charge!
 end

 def available_payment_methods
    @available_payment_methods ||= (
      Spree::PaymentMethod.available(:front_end, store: store) +
      Spree::PaymentMethod.available(:both, store: store)
    ).
      uniq
  end

  def ensure_available_shipping_rates
    if shipments.empty?
      # After this point, order redirects back to 'address' state and asks user to pick a proper address
      # Therefore, shipments are not necessary at this point.

     # errors.add(:base, Spree.t(:items_cannot_be_shipped)) && (return false)
    end
  end

  def select_order_number_prefix
    if user_id?
      if user.salesman_with_identifier?
        salesman = user.identifier
      elsif user.vendor? and user.vendor_detail.salesman.salesman_with_identifier?
        salesman_identifier = user.vendor_detail.salesman.identifier
      end
      salesman_identifier.blank? ? nil : salesman_identifier
    end
  end

  def generate_order_number(options = {})
    if ENV['USE_INVOICE_NUMBER_FOR_ORDER_NUMBER'] == 'true'
      invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
      self.number = "#{select_order_number_prefix}#{invoice_number.to_s}"
      self.invoice_number = invoice_number
      self.invoice_date = Date.today
    else
      options[:length]  ||= ORDER_NUMBER_LENGTH
      options[:letters] ||= ORDER_NUMBER_LETTERS
      possible = (0..9).to_a
      possible += ('A'..'Z').to_a if options[:letters]

      # Modifying prefix for salesman with identifier
      options[:prefix] = select_order_number_prefix || ORDER_NUMBER_PREFIX

      self.number ||= loop do
        # Make a random number.
        random = "#{options[:prefix]}#{(0...options[:length]).map { possible.sample }.join}"
        # Use the random  number if no other order exists with it.
        if self.class.exists?(number: random)
          # If over half of all possible options are taken add another digit.
          options[:length] += 1 if self.class.count > (10**options[:length] / 2)
        else
          break random
        end
      end
    end
  end

  def send_cancel_email
    # Our special handling goes here to change the series of the order and to change the range as well
    minimumNA = Spree::Order.select("substring(number, 3) as number").where("number like 'NA%'").map{|order| order.number.to_i}.sort.first
    if minimumNA.nil? || minimumNA >= 0
      minimumNA = -1
    else
      minimumNA -= 1
    end

    self.number = "NA" + minimumNA.to_s
    self.invoice_number = minimumNA
    save

    # Original code from the gem
    Spree::OrderMailer.cancel_email(self).deliver_later
  end
end