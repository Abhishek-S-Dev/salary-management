class Department < ApplicationRecord
  has_many :employees, inverse_of: :department, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
