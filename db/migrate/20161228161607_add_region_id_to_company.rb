class AddRegionIdToCompany < ActiveRecord::Migration[5.0]
  def self.up
    add_reference :companies, :region, foreign_key: true

    Company.all.each do |cmpy|
      region = Region.where(name: cmpy.old_region)[0]
      if region
        cmpy.region = region
        cmpy.save
      else
        puts "No region match for company : #{cmpy.name}"
      end
    end
  end

  def self.down
    remove_reference(:companies, :region, index: true, foreign_key: true)
  end
end
