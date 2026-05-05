class Employee < ApplicationRecord
  has_many :payroll_entries, dependent: :destroy

  validates :first_name, :last_name, :email, :base_salary, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :base_salary, numericality: { greater_than: 0 }
end
