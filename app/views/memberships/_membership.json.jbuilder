json.extract! membership, :id, :member_number, :belongs_to, :first_day, :last_day, :created_at, :updated_at
json.url membership_url(membership, format: :json)
