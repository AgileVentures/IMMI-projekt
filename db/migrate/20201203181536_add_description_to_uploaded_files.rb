class AddDescriptionToUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaded_files, :description, :string
  end
end
