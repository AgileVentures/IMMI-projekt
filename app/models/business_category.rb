class BusinessCategory < ApplicationRecord
  validates :name, presence: true

  has_and_belongs_to_many :shf_applications
  has_many :companies, through: :shf_applications
end
