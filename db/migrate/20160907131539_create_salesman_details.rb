class CreateSalesmanDetails < ActiveRecord::Migration
  def change
    create_table :salesman_details do |t|
      t.references :user, index: true
      t.string :identifier

      t.timestamps null: false
    end
  end
end
