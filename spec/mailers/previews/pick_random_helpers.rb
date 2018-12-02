module PickRandomHelpers

  # Note: random User instances can cause discrepencies between the email
  #       header and the body.  This is because the preview method is called
  #       twice - once to render the header and once to render the body.
  #       More info: https://github.com/rails/rails/issues/13430


  # return a random new membership application
  def random_shf_app(application_state = :new)

    app_ids = ShfApplication.where(state: application_state).pluck(:id)

    rand_id_index = Random.rand(app_ids.count)

    ShfApplication.find(app_ids[rand_id_index])

  end


  def random_user
    user_ids = User.pluck(:id)

    rand_id_index = Random.rand(user_ids.count)
    User.find( user_ids[rand_id_index] )

  end


  FIXTURE_DIR = File.join("#{Rails.root}",'spec','fixtures','uploaded_files')

  # Upload a random number of files for the membership application
  # Upload at least [min] files (where minimum is 1 by default)
  # and at most [max] file.
  # If the application already has uploaded files, add as needed to get to the random number.
  # If the application already has has more than the max number or more than the random number of files,
  # just go with what it has. (Don't delete anything; those files might be there for some other test or reason.)
  def upload_random_num_files(app,  min: 1, max: 5)

    random_num_files = Random.rand(min..max)

    if app.uploaded_files.count < random_num_files

      (random_num_files - app.uploaded_files.count).times do | i |

        file_txt =  File.open(File.join(FIXTURE_DIR, "uploaded-#{i}.txt"), 'w') do |f|
          f.puts "This is a dummy file created to stand in for a file a user has uploaded with their SHF membership application."
          f.puts "It was created by  #{self.class.name}::#{__method__} [#{__FILE__}  line #{__LINE__}]"
          f.puts "\nThis can be added to git so that it is another 'uploaded file' that the mail preview and other spec tests can use."
          f.puts "Or you can safely delete this file. (It will be recreated as needed by spec/mailers/previews/pick_random_helpers.rb )"
        end

        uploaded_file = UploadedFile.create(actual_file: file_txt, shf_application: app, actual_file_file_name:  "uploaded-#{i}.txt")
        app.uploaded_files << uploaded_file
      end

    end

  end


end
