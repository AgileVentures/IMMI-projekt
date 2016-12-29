class CreateRegions < ActiveRecord::Migration[5.0]
  def self.up
    create_table :regions do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    # This populates the 'regions' table for Swedish regions (aka counties),
    # as well as 'Sweden' and 'Online'.  This is used to specify the primary
    # region in which a company operates.
    #
    # This uses the 'city-state' gem for a list of regions (name and ISO code).
    # (That gem will also return a list of cities within region)
    
    CS.states(:se).each_pair { |k,v| Region.create(name: v, code: k.to_s) }
    Region.create(name: 'Sweden', code: nil)
    Region.create(name: 'Online', code: nil)
  end

  def self.down
    drop_table :regions
  end
end
