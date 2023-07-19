class AddLowestPriceToPrices < ActiveRecord::Migration[7.0]
  def change
    add_column :prices, :lowest_price, :float
  end
end
