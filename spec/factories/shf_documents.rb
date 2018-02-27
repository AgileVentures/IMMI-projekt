FactoryBot.define do


  # FIXTURE_DIR = File.join("#{Rails.root}",'spec','fixtures','uploaded_files')

  factory :shf_document, class: ShfDocument do
    title "SHF Doc Title"
    description "SHF Doc description"
    association :uploader, factory: :user, admin: true
  end


  trait :png do
    actual_file { File.new(File.join(FIXTURE_DIR, 'image.png')) }
  end

  trait :gif do
    actual_file { File.new(File.join(FIXTURE_DIR, 'image.gif')) }
  end

  trait :jpg do
    actual_file { File.new(File.join(FIXTURE_DIR, 'image.jpg')) }
  end

  trait :pdf do
    actual_file { File.new(File.join(FIXTURE_DIR, 'diploma.pdf')) }
  end

  trait :txt do
    actual_file { File.new(File.join(FIXTURE_DIR, 'specifications.txt')) }
  end

  trait :doc do
    actual_file { File.new(File.join(FIXTURE_DIR, 'microsoft-word.doc')) }
  end

  trait :docx do
    actual_file { File.new(File.join(FIXTURE_DIR, 'microsoft-word.docx')) }
  end

  trait :docm do
    actual_file { File.new(File.join(FIXTURE_DIR, 'microsoft-word.docm')) }
  end

  trait :exe do
    actual_file { File.new(File.join(FIXTURE_DIR, 'tred.exe')) }
  end

  trait :bin do
    actual_file { File.new(File.join(FIXTURE_DIR, 'tred.bin')) }
  end

end
