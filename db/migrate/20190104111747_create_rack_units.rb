class CreateRackUnits < ActiveRecord::Migration
  def change
    create_table :rack_units do |t|
      t.references :spree_variant, index: true, foreign_key: true
      t.references :spree_order, index: true, foreign_key: true
      t.references :rack_item, index: true, foreign_key: true
      t.string :state

      t.timestamps null: false
    end
  end
end
