json.extract! price, :id, :original_price, :discount_price, :product_id, :created_at, :updated_at
json.url price_url(price, format: :json)
