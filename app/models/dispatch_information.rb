class DispatchInformation < ActiveRecord::Base
  belongs_to :shipment, class_name: Spree::Shipment
  validates :number, presence: true, uniqueness: true
end
