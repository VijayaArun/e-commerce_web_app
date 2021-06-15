class CreateRemarks < ActiveRecord::Migration
  def change
    create_table :remarks do |t|
      t.text :remark
      t.references :visit, index: true, foreign_key: true
      t.references :spree_order, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
