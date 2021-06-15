module Spree
  module PermissionSets
    class DispatcherUser < PermissionSets::Base
      def activate!
        can :manage, Spree::Order
        can :ship, Spree::Shipment
        can :update, ManifestItem
        cannot :update_customer, Spree::User
      end
    end
  end
end
