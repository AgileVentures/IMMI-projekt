class BusinessCategory < ApplicationRecord
  has_ancestry

  PARENT_AND_CHILD_NAME_SEPARATOR = ' >> '

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :shf_applications
  has_many :companies, through: :shf_applications

  def self.for_search
    categories = []

    roots.order(:name).each do |category|
      categories << category
      categories += category.children.order(:name)
    end

    categories
  end

  def search_name
    return name if is_root?

    parent.name + PARENT_AND_CHILD_NAME_SEPARATOR + name
  end

end
