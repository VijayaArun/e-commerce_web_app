class UpdateRemarksTable < ActiveRecord::Migration
  def up
    drop_table :remarks
    create_table :remarks do |t|
      t.text :content
      t.string :action
      t.string :type, index: true

      t.timestamps null: false
    end

    add_index :remarks, [:action, :type]
  end

  def down
    remove_index :remarks, column: [:action, :type]
    drop_table :remarks
    create_table :remarks do |t|
      t.text :remark
      t.references :visit, index: true, foreign_key: true
      t.references :spree_order, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
