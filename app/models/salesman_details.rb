class SalesmanDetails < ActiveRecord::Base
  self.table_name = 'salesman_details'
  belongs_to :spree_user, class_name: Spree::User

  validates_length_of :identifier, :maximum => 4
  validates_format_of :identifier, :with => /\A[a-zA-Z]+\z/, unless: lambda { self.identifier.blank? }
  validates :identifier, uniqueness: { message: "Should be unique" }
end
