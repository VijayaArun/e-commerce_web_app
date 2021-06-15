     Spree::Core::Engine.class_eval do

		initializer "spree.salesman_permissions", before: :load_config_initializers do |_app|

		         Spree::RoleConfiguration.configure do |config|

		           config.assign_permissions :salesman, [Spree::PermissionSets::SalesmanUser]
               config.assign_permissions :dispatcher, [Spree::PermissionSets::DispatcherUser]
		         end

		      end
  end