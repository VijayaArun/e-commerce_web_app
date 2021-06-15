class AddDeletedAtToRackItems < ActiveRecord::Migration
  def change
    add_column :rack_items, :deleted_at, :datetime
    add_index :rack_items, :deleted_at
  end
end
