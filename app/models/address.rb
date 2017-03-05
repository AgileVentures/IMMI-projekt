class Address < ApplicationRecord

  belongs_to :addressable, polymorphic: true

  belongs_to :region

  belongs_to :kommun


  validates_presence_of :addressable

  validates_presence_of :country


  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }

end
