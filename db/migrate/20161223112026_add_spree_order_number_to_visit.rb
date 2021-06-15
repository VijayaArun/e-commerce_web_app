class AddSpreeOrderNumberToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :spree_order_number, :string, null: true
  end
end
