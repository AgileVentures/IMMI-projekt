class Condition < ApplicationRecord
  serialize :config

  validates :class_name, presence: true
end
