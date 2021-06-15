class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :salesman_id
      t.integer :vendor_id
      t.datetime :in_time
      t.datetime :out_time

      t.timestamps null: false
    end
  end
end
