class AddRegionIdToCompany < ActiveRecord::Migration[5.0]
  def self.up
    add_reference :companies, :region, foreign_key: true
  end

  def self.down
    remove_reference(:companies, :region, index: true, foreign_key: true)
  end
end
