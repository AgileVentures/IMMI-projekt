class MemberPage < ApplicationRecord
  validates :filename, presence: true, uniqueness: true
  # add uniqueness on db

  def self.title(file_name)
    member_page = find_or_create_by(filename: file_name)
    member_page.title || file_name.capitalize
  end
end
