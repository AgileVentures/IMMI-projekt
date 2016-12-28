class RenameRegionToOldRegion < ActiveRecord::Migration[5.0]
  def change
    rename_column :companies, :region, :old_region
  end
end
