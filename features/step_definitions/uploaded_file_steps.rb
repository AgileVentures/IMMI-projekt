# Steps for UploadedFiles

And(/^these files have been uploaded:?/) do |table|
  # If the UploadedFile does not already exist, create it.  (It will not be associaed with any application.)
  # If it does exist, set the description

  # | user_email | file name | description |
  table.hashes.each do |hash|

    user = User.find_by(email: hash['user_email'].downcase)
    uploaded_file_name = hash['file name']
    description = hash['description']

    file_already_uploaded = UploadedFile.find_by(user: user, actual_file_file_name: uploaded_file_name)
    if file_already_uploaded
      file_already_uploaded.update!(description: description)
    else
      if file_fixture_exists?(uploaded_file_name, 'these files have been uploaded')
        File.open(Rails.root.join(UPLOADED_FILES_DIR, uploaded_file_name), 'r') do |f|
          UploadedFile.create!(user: user,
                               description: description,
                               actual_file: f,
                               actual_file_file_name: uploaded_file_name)
        end
      end
    end
  end

end


# Find a string or not in the uploaded_files table
# (= the list of uploaded files on the #index page
And "I should{negate} see {capture_string} in the list of uploaded files" do |negated, expected_string|
  step %{I should#{negated ? ' not' : ''} see "#{expected_string}" in the div with id "uploaded-files-list"}
end

