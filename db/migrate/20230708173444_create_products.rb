class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :quantity
      t.string :category
      t.string :full_category
      t.string :image_url

      t.timestamps
    end
  end
end
