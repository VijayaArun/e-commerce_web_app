module Spree
  module PermissionSets
    class SalesmanUser < PermissionSets::Base
      def activate!
        can :manage, Spree::User
      end
    end
  end
end
