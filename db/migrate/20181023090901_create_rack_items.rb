class CreateRackItems < ActiveRecord::Migration
  def change
    create_table :rack_items do |t|
      t.references :spree_variant, index: true, foreign_key: true
      t.references :rack, index: true, foreign_key: true
      t.integer :count_on_hand

      t.timestamps null: false
    end
  end
end
