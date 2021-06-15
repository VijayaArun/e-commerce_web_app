class AddColumnToOrderDetail < ActiveRecord::Migration
  def change
    add_column :order_details, :transport_info, :string
    add_column :order_details, :agent_info, :string
  end
end
