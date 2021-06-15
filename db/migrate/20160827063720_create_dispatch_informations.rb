class CreateDispatchInformations < ActiveRecord::Migration
  def change
    create_table :dispatch_informations do |t|
      t.integer :number

      t.timestamps null: false
    end
  end
end
