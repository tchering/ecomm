json.extract! admin_product, :id, :title, :description, :price, :stock, :active, :category_id, :created_at, :updated_at
json.url admin_product_url(admin_product, format: :json)
