require 'rails_helper'
require_relative File.join(Rails.root, 'db/seeders/app_configuration_seeder')


RSpec.describe Seeders::AppConfigurationSeeder do
  let(:fixture_dir) { File.join("#{Rails.root}", 'spec', 'fixtures', 'uploaded_files') }

  before(:each) do
    allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)
    allow(described_class).to receive(:tell).and_return(false)
    allow(described_class).to receive(:log_str).and_return(false)
  end


  describe '.seed' do

    it 'returns nil and logs a warning message if an AppConfiguration already exists' do
      expect(described_class).to receive(:tell).with(/already exists; not seeded/)
      expect(described_class).not_to receive(:seed_app_config)

      described_class.seeded_class.create(site_name: 'site name',
                                          site_meta_title: 'meta title stuff',
                                          site_meta_image: File.new(File.join(fixture_dir, 'image.png')) )

      expect(described_class.seed).to be_nil
    end

    context 'an AppConfiguration does not already exist' do

      it 'calls seed_app_config' do
        expect(described_class).to receive(:seed_app_config)
        described_class.seed
      end
    end
  end


  describe 'seed_app_config' do

    it 'explicitly calculates and saves the site meta image dimensions' do
      allow(AdminOnly::MasterChecklist).to receive(:find_by).and_return(nil)

      # will be called once with save, and then again explicitly after the save
      expect_any_instance_of(AdminOnly::AppConfiguration).to receive(:update_site_meta_image_dimensions).twice
      described_class.seed
    end

    it 'finds the MasterChecklist with displayed text = Medlemsåtagande' do
      expect(AdminOnly::MasterChecklist).to receive(:find_by)
                                              .with(displayed_text: 'Medlemsåtagande')
      described_class.seed
    end
  end


  it 'seeded_class is AdminOnly::AppConfiguration' do
    expect(described_class.seeded_class).to eq AdminOnly::AppConfiguration
  end


  describe 'app_config_file' do
    it 'gets a new File from the app_config_files_dir' do
      allow(File).to receive(:new)

      expect(File).to receive(:join).with(described_class.app_config_files_dir, 'some file name')
      described_class.app_config_file('some file name')
    end
  end


  it 'app_config_files_dir is ./app_config_files' do
    expect(described_class.app_config_files_dir).to match(/app_config_files/)
  end
end
