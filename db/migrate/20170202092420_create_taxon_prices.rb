class CreateTaxonPrices < ActiveRecord::Migration
  def change
    create_table :taxon_prices do |t|
      t.integer  "taxon_id", limit: 4, null: false
      t.decimal  "amount", precision: 10, scale: 2
      t.string   "currency", limit: 255
      t.datetime "deleted_at"
      t.boolean  "is_default", default: true, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "country_iso", limit: 2
    end
    add_index "taxon_prices", ["country_iso"], name: "index_taxon_prices_on_country_iso", using: :btree
    add_index "taxon_prices", ["taxon_id", "currency"], name: "index_taxon_prices_on_taxon_id_and_currency", using: :btree
  end
end
