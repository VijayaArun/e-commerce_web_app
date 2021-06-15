class VendorDetail < Spree::Base
  acts_as_paranoid
  # belongs_to :user, class_name: Spree::User , foreign_key: "id"
  # belongs_to :user, class_name: Spree::User, foreign_key: "id"
  belongs_to :user, class_name: Spree::User
  belongs_to :salesman, class_name: Spree::User, foreign_key: :salesman_id
end