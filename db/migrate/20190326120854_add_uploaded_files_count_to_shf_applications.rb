class AddUploadedFilesCountToShfApplications < ActiveRecord::Migration[5.2]
  def self.up
    add_column :shf_applications, :uploaded_files_count, :integer, null: false, default: 0

    # Cannot update counters here with the CounterCulture gem because the ActiveRecord models
    #   no longer match the relationships/associations at this point.
    # UploadedFile.counter_culture_fix_counts
  end

  def self.down
    remove_column :shf_applications, :uploaded_files_count
  end
end
