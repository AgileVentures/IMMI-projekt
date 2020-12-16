json.extract! uploaded_file, :id, :created_at, :updated_at, :actual_file_file_name, :description, :actual_file_content_type, :actual_file_file_size, :actual_file_updated_at, :user_id, :shf_application_id
json.url uploaded_file_url(uploaded_file, format: :json)
