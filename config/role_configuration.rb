Spree::RoleConfiguration.configure do |config|
      config.assign_permissions :salesman, [
        Spree::PermissionSets::SalesmanUser
      ]
    end