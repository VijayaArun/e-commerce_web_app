class AddCreatedByIdToSpreeUsers < ActiveRecord::Migration
	def change
		add_column :spree_users, :created_by_id, :integer, :default => 1
  	end
end
