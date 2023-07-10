json.extract! product, :id, :name, :quantity, :category, :full_category, :image_url, :created_at, :updated_at
json.url product_url(product, format: :json)
