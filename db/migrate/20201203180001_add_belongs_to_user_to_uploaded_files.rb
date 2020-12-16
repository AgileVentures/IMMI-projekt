class AddBelongsToUserToUploadedFiles < ActiveRecord::Migration[5.2]

  def up
    add_reference :uploaded_files, :user, index: true, foreign_key: true

    # Set the User to the SHF Application user
    execute "UPDATE uploaded_files SET user_id = shf_applications.user_id  FROM shf_applications WHERE shf_applications.id = uploaded_files.shf_application_id AND uploaded_files.user_id IS NULL"
    UploadedFile.counter_culture_fix_counts
  end

  def down
    remove_reference :uploaded_files, :user, index: true, foreign_key: true
  end
end
