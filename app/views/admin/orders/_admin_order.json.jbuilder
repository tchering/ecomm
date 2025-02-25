json.extract! order, :id, :name, :email, :address, :total, :status, :created_at, :updated_at
json.url admin_order_url(order, format: :json)
