Spree::User.class_eval do
  has_one :salesman_details
  has_one :vendor_detail , dependent: :destroy
  has_one :role_user
  has_one :role, through: :role_user
  has_many :vendor_payments
  has_many :created_users, class_name: Spree::User, foreign_key: "created_by_id"
  has_many :sales_vendor_details, class_name: VendorDetail, foreign_key: 'salesman_id'
  has_many :vendors, class_name: Spree::User, through: :sales_vendor_details, source: :user

  belongs_to :created_by, class_name: Spree::User, foreign_key: "created_by_id"

  delegate :identifier, to: :salesman_details, allow_nil: true
  delegate :gst_number, to: :vendor_detail, allow_nil: true
  before_validation  :check_salesman_details, on: :create
  validates_length_of :gst_number, :allow_nil => true, :maximum => 15

  after_create :send_welcome_mail
  accepts_nested_attributes_for :salesman_details, reject_if: :not_salesman?
  accepts_nested_attributes_for :vendor_detail, reject_if: :not_vendor?

  money_methods :total_outstanding_amount

  %w(salesman admin vendor dispatcher).each do |role|
    define_method("#{role}?".to_sym)   {
      role.in?(spree_roles.collect(&:name))
    }
  end

  def not_salesman?
      !salesman?
  end

  def not_vendor?
    !vendor?
  end

  def salesman_with_identifier?
    identifier.present?
  end

  def check_salesman_details
    build_salesman_details if salesman? and salesman_details.blank?
  end

  def set_uniq_identifier(email)
    identifier = email.first(3).upcase
    if (SalesmanDetails.where(identifier: identifier).exists?)
      ("A".."Z").each do |letter|
        new_identifier = identifier + letter
        if (SalesmanDetails.where(identifier: new_identifier).exists?)
          next
        else
          return new_identifier
          break
        end
      end
    else
      return identifier
    end
  end

  def total_outstanding_amount(reload_value=nil)
    if vendor_detail.blank? or reload_value
      shipments = []
      orders.each do |order|
        order.shipments.each do |shipment|
          if shipment.state == "shipped"
            shipments << shipment
          end
        end
      end      

      total_outstanding = shipments.collect(&:outstanding_balance).sum
      
      vendor_payments = self.vendor_payments
      total_payments = 0
      vendor_payments.each do |vendor_payment|
       total_payments += vendor_payment.payment
      end
      total_outstanding -= total_payments
      
      total_outstanding

    else
      vendor_detail.outstanding_amount
    end
  end

  def store_outstanding_amount!
    if vendor_detail.present? || vendor_payments.present?
      vendor_detail.update_attributes(outstanding_amount: total_outstanding_amount(true))
      vendor_detail.user.update_attributes(updated_at: Time.now)
    end
  end

  private
  # send welcome email to user
  def send_welcome_mail
    UserMailer.welcome(self).deliver_now
  end

end