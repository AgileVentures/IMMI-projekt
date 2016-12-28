class AddRegionIdToCompany < ActiveRecord::Migration[5.0]
  def change
    add_reference :companies, :region, foreign_key: true
  end
end
