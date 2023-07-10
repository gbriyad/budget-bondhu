class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.float :original_price
      t.float :discount_price
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
